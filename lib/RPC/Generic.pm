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

=method _rpc METHOD,PARAMETERS

Generic method for requesting the server to run I<METHOD> with provided I<PARAMETERS>.

=cut

sub _rpc {
	my ($self, $method, @params) = @_;
	my $remote = $self->_remote();
	my $response;
	my $request = $self->_rpc_request($method, @params);
	eval {
		$remote->print($self->_serialize($request));
		local $/;
		$response = $self->_deserialize($remote->getline());
	};
	if(my $e = $@){
		$response = $self->_rpc_response($request, undef, $self->_rpc_error($e));
	}
	return $response;
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

=cut

sub _rpc_request {
	my ($self, $method, @params) = @_;
	return {id => $self->_rpc_id, method => $method, params => [@params]};
}

=method _rpc_response ID,RESULT,ERROR

Return an RPC response object.

=cut

sub _rpc_response {
	my ($self, $id, $result, $error) = @_;
	# allow $id to be a rpc_request hash
	return {id => (ref($id) ? $id->{id} : $id), result => $result, error => $error};
}

# NOTE: no need for generic DESTROY; it will be called automatically on sub-objects

1;
