package RPC::Generic;
# ABSTRACT: RPC::Generic - Tiny, very customizable (subclassable) module for RPC style communication

=head1 SYNOPSIS

	package MyRPC;
	our @ISA = qw(RPC::Generic);

	# customize class by overriding methods

	package main;

	$mine = MyRPC->new(option => 'value');
	$data = $mine->_rpc('method', @parameters);

=cut

use strict;
use warnings;

# start with base serializer, but expect classes to overload
use RPC::Generic::Serializer;

=method new LIST

Instantiate RPC object.  Optional I<LIST> of key/value pairs overwrites defaults.

Options are defined by subclasses.

=cut

sub new {
	my $class = shift;
	my $self = {
		_rpc_id => 0,
		private => {}, # reserved for subclasses
		_defaults(),
		@_
	};
	bless($self, $class);
}

# TODO: AUTOLOAD

=method _defaults

Return a list (hash) of default options to be used at initialization.

=cut

sub _defaults { () }

=method _message_class

Return class name (string) for creating message objects.
Will attempt to load a module by appending '::Message'
to the current [sub]class.
If not found, returns L<RPC::Generic::Message>.

=cut

# TODO: search all @ISA's ?

sub _message_class {
	my ($self) = @_;
	# cache the result
	$self->{message_class} ||= do {
		# try subclass::Message, fall back to __PACKAGE__::Message
		my $class = ref($self);
		my $message_class = eval {
			foreach my $base ( $class, __PACKAGE__ ){
				my $mod = "${base}::Message";
				return $mod if eval "require $mod;";
			}
		};
		# call as function rather than object method because $class does not inherit from Serializer
		RPC::Generic::Serializer::copy_methods_to_namespace($class, $message_class);
		$message_class; # return
	};
}

=method _rpc METHOD,PARAMETERS

Generic method for requesting the server to run I<METHOD> with provided I<PARAMETERS>.

=cut

sub _rpc {
	my ($self, $method, @params) = @_;
	my $remote = $self->_remote();
	my $response;
	my $request = $self->_rpc_request($method, @params);
	eval {
		# explicitly stringify in case remote doesn't
		$remote->print("$request");
		$response = $self->_rpc_response($remote->getline);
	};
	if(my $e = $@){
		$response = $self->_rpc_response($request, undef, $self->_rpc_error($e));
	}
	# return just the data since this is a simple, generic interface
	return $response->data;
}

=method _rpc_error EXPR

Return an error in the desired format.
Allows subclasses to easily overwrite and create Exception objects if desired.
Default simply returns I<EXPR>.

=cut

sub _rpc_error {
	return $_[1]; # just return the argument.  stub for subclasses
}

=method _rpc_id

Return a new id to use with a new request.
Defaults to incrementing an integer.

=cut

sub _rpc_id {
	++$_[0]->{_rpc_id};
}

=method _rpc_request METHOD,PARAMETERS

Return an RPC request object for the given I<METHOD> and I<PARAMETERS>.
See L<RPC::Generic::Message/request>.

=cut

sub _rpc_request {
	my $self = shift;
	return $self->_message_class->request($self->_rpc_id, @_);
}

=method _rpc_response ID,RESULT,ERROR

Return an RPC response object.
See L<RPC::Generic::Message/response>.

=cut

sub _rpc_response {
	my $self = shift;
	return $self->_message_class->response(@_);
}

# NOTE: no need for generic DESTROY; it will be called automatically on sub-objects

1;
