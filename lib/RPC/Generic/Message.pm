package RPC::Generic::Message;
# ABSTRACT: base class for RPC request and response messages

=head1 SYNOPSIS

	use RPC::Generic::Message;
	my $req = RPC::Generic::Message->request($id, $method, @params);
	my $res = RPC::Generic::Message->response($id, $result, $error);
	my $msg = RPC::Generic::Message->new({id => ...});

	...

	# automatic [de]serialization:
	print $socket $req;
	$response = RPC::Generic::Message->new(<$socket>);

The class uses overloading to make it's use as simple as possible.
It will automatically deserialize when used as a string,
and can also be dereferenced as a normal I<HASH> object.

The C<new()> method expects an anonymous hash ref as its object
(unless of course you've defined different semantics in your base class).
The reference is retained, so don't send a value that you have
other references to somewhere (like a variable)
unless you know what you are doing.

If you want to use a previous variable but don't know what you're doing,
do something like this:

	my $hash = {id => 1, method => 'oops', params => []};
	RPC::Generic::Message->new({%$h});

to break the reference first.

=cut

use strict;
use warnings;
# start with base serializer in case this class is used by itself
# RPC::Generic will share its serialization methods with this class
use RPC::Generic::Serializer;
use overload
	'%{}' => \&data,
	'""' => \&stringify;

=method new EXPR

X<new>

Initialize new Message.
I<EXPR> should be a hash reference,
or a string which will be automatically deserialized.

When creating a response,
a request object can be passed as the id field and the id will be extracted.

=cut

sub new {
	my ($class, $obj) = @_;
	# automatically deserialize (if not already a reference)
	$obj = $class->_deserialize($obj) if ref($obj) eq '';
	# allow a previous object to be supplied
	$obj->{id} = $obj->{id}->id if ref($obj->{id});
	# Bless a reference to an array (rather than a HASH or simply the object)
	# to avoid deep recursion when dereferencing and overloading.
	# Using a reference to the hash ref is somewhat nifty
	# (allowing $$var to get straight to the data),
	# but is probably also confusing and doesn't allow room for growth.
	bless [$obj], $class;
}

=method data

Returns the raw data of the message object.

=cut

sub data {
	$_[0]->[0];
}

=method id

Returns the id of the RPC message.

=cut

sub id {
	$_[0]->data->{id};
}

=method request ID,METHOD,PARAMETERS

Creates a new RPC request message.

=over

=item * I<ID> is the id of the RPC request.

=item * I<METHOD> is the name of the remote method to call.

=item * I<PARAMETERS> is a list of arguments to send to the method.

=back

=cut

sub request {
	my $class = shift;
	return $class->new($_[0]) if @_ == 1;
	my ($id, $method, @params) = @_;
	return $class->new({id => $id, method => $method, params => [@params]});
}

=method response ID,RESULT,ERROR

Creates a new RPC response message.

=over

=item * I<ID> is the id of the RPC request (or a request object (see L</new>)).

=item * I<RESULT> is the data returned from the invoked request method.

=item * I<ERROR> if there was an error invoking the requested method.

=back

=cut

sub response {
	my $class = shift;
	return $class->new($_[0]) if @_ == 1;
	my ($id, $result, $error) = @_;
	return $class->new({id => $id, result => $result, error => $error});
}

=method stringify

Serialize the object.
Used with operator overloading (C<"">).

=cut

sub stringify {
	$_[0]->_serialize($_[0]->data);
}

1;
