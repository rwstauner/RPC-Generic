package RPC::Generic::Serializer::StorableN;
use strict;
use warnings;
use Storable ();
use parent 'RPC::Generic::Serializer';

=head1 SYNOPSIS

Use L<Storable|Storable>'s C<nfreeze()> and C<thaw()> methods for serialization.

	package MyRPC;
	use parent 'RPC::Generic';
	use RPC::Generic::Serializer::StorableN;

Uses C<nfreeze()> because RPC often means we're going over a network.

See L<RPC::Generic::Serializer>.

=cut

sub _serialize {
	Storable::nfreeze($_[1]);
}

sub _deserialize {
	Storable::thaw($_[1]);
}

1;

=head1 SEE ALSO

=for :list
* L<Storable>

=cut
