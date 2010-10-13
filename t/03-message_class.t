use Test::More tests => 2;

PACK: {
	package TestRPC;
	use parent 'RPC::Generic';
	use RPC::Generic::Serializer::StorableN;
}

my $rpc = TestRPC->new();
is($rpc->_message_class, 'RPC::Generic::Message', 'generic class');

PACK: {
	package TestRPC::Message;
	our @ISA = qw(RPC::Generic::Message);
	NOREQ: {
		# don't attempt to require it
		(my $fake_path = __PACKAGE__) =~ s/::/\//;
		$fake_path .= ".pm";
		$INC{$fake_path} = __FILE__;
	}
}

$rpc = TestRPC->new();
is($rpc->_message_class, 'TestRPC::Message', 'subclass');
