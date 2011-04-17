use strict;
use warnings;
use Test::More 0.96 tests => 2 * 2;

PACK: {
	package TestRPC;
	use parent 'RPC::Generic';
	use RPC::Generic::Serializer::StorableN;
}

sub try_it ($) {
	my ($expected) = @_;
	my $rpc = TestRPC->new();
	is($rpc->_message_class, $expected, "found $expected");
	isa_ok($rpc->_message_class->new(), $expected, "instantiate $expected");
}

try_it 'RPC::Generic::Message';

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

try_it 'TestRPC::Message';
