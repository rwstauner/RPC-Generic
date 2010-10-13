package RPC::Generic::Remote::TCP;
# ABSTRACT: Inherits from IO::Socket::INET for simple I/O over a TCP socket

=head1 SYNOPSIS

Inherits from L<RPC::Generic::Remote|RPC::Generic::Remote>.

Establishes a TCP connection using L<IO::Socket::INET|IO::Socket::INET>
with the parameters returned by C<_remote_parameters()>
and caches it on the rpc object.

	package MyRPC;
	our @ISA = qw(RPC::Generic);
	use RPC::Generic::Remote::TCP;

	sub _remote_parameters {
		(PeerAddr => 'localhost', PeerPort => 1234);
	}

=cut

use strict;
use warnings;
use parent qw(RPC::Generic::Remote IO::Socket::INET);

=method _remote

Initializes the paramters to C<< (Proto => 'tcp') >> and expects the rest
(host, port, etc) to be defined in C<_remote_parameters()>.

=cut

sub _remote {
	my ($self) = @_;
	$self->{remote} ||= __PACKAGE__->new(
		Proto => 'tcp',
		$self->_remote_parameters()
	) or die("Remote TCP connection failed: $!");
}

# nothing else is needed since this already inherits from IO

1;

=head1 SEE ALSO

=for :list
* L<IO::Socket::INET>.

=cut
