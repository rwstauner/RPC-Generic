package RPC::Generic;
# ABSTRACT: RPC::Generic - Tiny, very customizable (subclassable) module for RPC style communication

=head1 SYNOPSIS

	package MyRPC;
	our @ISA = qw(RPC::Generic);

	# customize class by overriding methods

	package main;

	$mine = MyRPC->new(option => 'value');
	$data = $mine->rpc('method', @parameters);

=cut

use strict;
use warnings;

use RPC::Generic::Serializer;

=over

=item new LIST

Instantiate RPC object.  Optional LIST of key/value pairs overwrites defaults.

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

=item _defaults

Return a list (hash) of default options to be used at initialization.

=cut

sub _defaults { () }

=item _rpc METHOD,PARAMETERS

Generic method for requesting the server to run METHOD with provided PARAMETERS.

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

=item _rpc_error

Return an error in the desired format.
Allows subclasses to easily overwrite and create Exception objects if desired.

=cut

sub _rpc_error {
	return $_[1]; # just return the argument.  stub for subclasses
}

=item _rpc_id

Get a new id to use with a new request.

=cut

sub _rpc_id {
	++$_[0]->{_rpc_id};
}

=item _rpc_request METHOD,PARAMETERS

Return an RPC request object for the given method and parameters.

=cut

sub _rpc_request {
	my ($self, $method, @params) = @_;
	return {id => $self->_rpc_id, method => $method, params => [@params]};
}

=item _rpc_response ID,RESULT,ERROR

Return an RPC response object.

=cut

sub _rpc_response {
	my ($self, $id, $result, $error) = @_;
	# allow $id to be a rpc_request hash
	return {id => (ref($id) ? $id->{id} : $id), result => $result, error => $error};
}

# NOTE: no need for generic DESTROY; it will be called automatically on sub-objects

1;
