package RPC::Generic::Serializer::JSON;
# ABSTRACT: Serialzer that uses JSON module
use strict;
use warnings;
use JSON ();
use parent 'RPC::Generic::Serializer';

=head1 SYNOPSIS

Use L<JSON|JSON>'s C<encode_json()> and C<decode_json()>
methods for serialization.

	package MyRPC;
	use parent 'RPC::Generic';
	use RPC::Generic::Serializer::JSON;

See L<RPC::Generic::Serializer>.

=cut

sub _serialize {
	JSON::encode_json($_[1]);
}

sub _deserialize {
	JSON::decode_json($_[1]);
}

1;

=head1 SEE ALSO

=for :list
* L<JSON>

=cut
