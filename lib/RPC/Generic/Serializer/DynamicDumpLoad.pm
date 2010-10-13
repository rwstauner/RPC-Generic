package RPC::Generic::Serializer::DynamicDumpLoad;
# ABSTRACT: Serializer that uses Dump() and Load() from specified module
use strict;
use warnings;
use parent 'RPC::Generic::Serializer';

=head1 SYNOPSIS

This is an example of an L<RPC::Generic::Serializer>.

It, too, is generic.
It [de]serializes using (yet undefined) functions named C<Dump()> and C<Load()>.

You can choose which module's C<Dump()> and C<Load()> functions to use
by passing the module name as the first argument to "use":

	package MyRPC;
	use parent 'RPC::Generic';
	use RPC::Generic::Serializer::DynamicDumpLoad qw(YAML);

This will require the specified module and call it's C<import()> function
(sending any supplied arguments) with the goal that the module will export
functions named C<Dump()> and C<Load()> into this namespace.

=cut

sub import {
	my $class = shift;
	my $caller = caller();
	# we need call import() from the correct package
	$class->require_module(shift)->import(@_);
	$class->copy_methods_to_namespace($caller);
}

sub _serialize {
	Dump($_[1]);
}

sub _deserialize {
	Load($_[1]);
}

1;
