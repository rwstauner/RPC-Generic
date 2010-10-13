use strict;
package main;
use utf8;
use POSIX ':sys_wait_h';
use Test::More tests => 2;

our %socket = (qw(host localhost port), ($ENV{TEST_PORT} || 50000));

{
	package TestTCPRPC;
	use parent 'RPC::Generic';
	use RPC::Generic::Serializer::StorableN;
	use RPC::Generic::Remote::TCP;

	sub _remote_parameters {
		my ($self) = @_;
		return (PeerAddr => $self->{host}, PeerPort => $self->{port});
		
	}
}

my $rpc = TestTCPRPC->new(%socket);
my $Message = $rpc->_message_class;
my $text = localtime() . " | héllÖ Ɫ ܗ\n";

$SIG{CHLD} = 'IGNORE';
my $pid;
if( $pid = fork ){
	sleep 1;
	my $res = $rpc->_rpc('echo', $text);
	is($res->{result}, $text);
	is($res->{error}, undef);
	wait;
} else {
	die("Failed to fork: $!") unless defined($pid);
	my $server = IO::Socket::INET->new(
		Proto => 'tcp',
		Listen => 1,
		LocalAddr => $socket{host},
		LocalPort => $socket{port},
		Reuse => 1
	) or die("TCP failed to lisen: $!");
	$server->autoflush(1);

	if( my $client = $server->accept('RPC::Generic::Remote::TCP') ){
		$client->autoflush(1);
		my $req = $Message->request($client->getline);
		my $res = $Message->response($req,
			$req->{method} eq 'echo' ?
				($text, undef) :
				(undef, "Unknown rpc")
			);
		$client->print($res);
	} else {
		die("Nobody called: $!");
	}
	exit;
}
