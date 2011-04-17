package RPC::Generic::Remote;
# ABSTRACT: Base class for RPC Remote objects (IO-like interfaces)

=head1 SYNOPSIS

RPC::Generic expects a remote to be an IO-like object,
so if you are not inheriting from IO
you may need to define your own C<print()> and C<readline()> functions
(and/or overload the C<< "<>" >> operator).

See the tests for an example of this.

An L<RPC::Generic|RPC::Generic> subclass should overwrite
C<_remote_parameters()> to make necessary options available.

	package MyRPC::Remote;
	our @ISA = qw(RPC::Generic::Remote IO::Handle);
	sub _remote {
		$_[0]->{remote} ||= __PACKAGE__->new($_[0]->_remote_parameters());
	}

See example subclassess in F<RPC/Generic/Remote/*.pm>.

=cut

use strict;
use warnings;
use Carp qw(croak carp);

sub import {
	my $class = shift;
	my $caller = caller(); # the package "use"ing this module
	no strict 'refs';
	*{"${caller}::_remote"} = *{"${class}::_remote"};
}

=method _remote

This method gets exported to the L<RPC::Generic|RPC::Generic> class
that imports it to provide simple access to the remote object.

It should return an instance of a Remote.

	$remote = $rpc->_remote;
	$remote->print("$request");
	$response = <$remote>;

=cut

sub _remote {
	croak('_remote() method undefined!  See documentation for ' . __PACKAGE__);
}

1;

=head1 SEE ALSO

=for :list
* L<RPC::Generic::Remote::TCP>
* L<perlop>
* L<IO>

=cut
