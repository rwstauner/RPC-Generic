use strict;
package main;
use utf8;
use POSIX ':sys_wait_h';
use Test::More;

plan skip_all => 'TEST_TCP_PORT set to false' if defined($ENV{TEST_TCP_PORT}) && !$ENV{TEST_TCP_PORT};

my @test_data = (
	localtime() . " | héllÖ Ɫ ܗ\n",
	[1 .. 20],
	{hello => 'there'},
	":-P
இୱ𐏊⣉؇떾쑜흂ੴᾟीஙொோᚏൊᛤ◪✞ᐒᙲ⣷௵௴௺ൣឈஔऔꙬꙪꙮ‱⌫⌨𐎯ୋ
	" x 10_001 # cool-looking characters from character map (works x 1_000_000)
);
plan tests => 2 * (@test_data + 1);

our %socket = (qw(host localhost port), ($ENV{TEST_TCP_PORT} || 50000));

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

sub unknown { 'Unknown RPC: ' . $_[0]; }

my $rpc = TestTCPRPC->new(%socket);
my $Message = $rpc->_message_class;

$SIG{CHLD} = 'IGNORE';
my $pid;
if( $pid = fork ){
	sleep 1;
  foreach my $data ( @test_data ){
	my $t = time();
	my $res = $rpc->_rpc('echo', $data, $t);
	is_deeply($res->{result}, [$data, $t]);
	is($res->{error}, undef);
  }
	my $res = $rpc->_rpc('oops', ':-P');
	is($res->{result}, undef);
	is($res->{error}, unknown('oops'));
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
  foreach ( 1 .. @test_data + 1 ){
		$client->autoflush(1);
		my $req = $Message->request($client->getline);
		my $res = $Message->response($req,
			$req->{method} eq 'echo' ?
				($req->{params}, undef) :
				(undef, unknown($req->{method}))
			);
		$client->print($res);
  }
	} else {
		die("Nobody called: $!");
	}
	exit;
}
