use Test::More;
my $times = 3;
plan tests => 4 * $times;

{
	package TestEcho;

	# echo server for easy testing
	sub new { bless [], $_[0]; }
	sub print { $_[0]->[0] = $_[1]; }
	sub getline { $_[0]->[0]; }
}

{
	package TestRPC;
	use parent 'RPC::Generic';
	use RPC::Generic::Serializer::StorableN;

	sub _remote {
		$_[0]->{remote} ||= TestEcho->new();
	}

	# so we can test the id's later
	our $rpc_id = 0;
	sub _rpc_id { ++$rpc_id; }
}

my $rpc = TestRPC->new();

foreach (1 .. $times){
	my ($method, @params) = ('foo', 'bar', $_, 'cheese');
	my $res = $rpc->_rpc($method, @params);
	isa_ok($res, 'HASH');
	is($res->{id}, $TestRPC::rpc_id, 'response id matches');
	is($res->{method}, $method, 'method matches');
	is_deeply($res->{params}, \@params, 'parameters match');
}
