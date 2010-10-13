package RPC::Generic::Serializer::DynamicFreezeThaw;
use strict;
use warnings;
use parent 'RPC::Generic::Serializer';

=head1 SYNOPSIS

This is an example of an L<RPC::Generic::Serializer>.

It, too, is generic.
It [de]serializes using (yet undefined) functions named C<freeze()> and C<thaw()>.

You can choose which module's C<freeze()> and C<thaw()> functions to use
by passing the module name as the first argument to "use":

	package MyRPC;
	use parent 'RPC::Generic';
	use RPC::Generic::Serializer::DynamicFreezeThaw qw(Storable freeze thaw);

This will require the specified module and call it's C<import()> function
(sending any supplied arguments) with the goal that the module will export
functions named C<freeze()> and C<thaw()> into this namespace.

=cut

sub import {
	my $class = shift;
	my $caller = caller();
	# we need call import() from the correct package
	$class->require_module(shift)->import(@_);
	$class->copy_methods_to_namespace($caller);
}

sub _serialize {
	freeze($_[1]);
}

sub _deserialize {
	thaw($_[1]);
}

1;
