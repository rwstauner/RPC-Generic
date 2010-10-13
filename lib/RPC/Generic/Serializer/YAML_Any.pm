package RPC::Generic::Serializer::YAML_Any;
# ABSTRACT: Serializer that uses YAML::Any
use strict;
use warnings;
use YAML::Any ();
use parent 'RPC::Generic::Serializer';

=head1 SYNOPSIS

Use L<YAML::Any|YAML::Any>'s C<Dump()> and C<Load()> methods for serialization.

	package MyRPC;
	use parent 'RPC::Generic';
	use RPC::Generic::Serializer::YAML_Any;

C<$!> and C<$@> are localized before calling L<YAML::Any|YAML::Any>'s methods
so that the global variables are not overwritten
during it's normal trial-and-error operations.
Actual errors will still propogate normally.

See L<RPC::Generic::Serializer>.

=cut

sub _serialize {
	local ($!,$@);
	YAML::Any::Dump($_[1]);
}

sub _deserialize {
	local ($!,$@);
	YAML::Any::Load($_[1]);
}

1;

=head1 SEE ALSO

=for :list
* L<YAML::Any>

=cut
