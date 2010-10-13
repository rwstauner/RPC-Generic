my @serializers = (
	[qw(RPC::Generic::Serializer::DynamicDumpLoad YAML::Tiny)],
	[qw(RPC::Generic::Serializer::DynamicDumpLoad YAML::Syck)],
	[qw(RPC::Generic::Serializer::DynamicDumpLoad YAML)],
	[qw(RPC::Generic::Serializer::DynamicFreezeThaw Storable freeze thaw)],
# having problems with FreezeThaw (i've never used it so ignore it for now)
#	[qw(RPC::Generic::Serializer::DynamicFreezeThaw FreezeThaw freeze thaw)],
	[qw(RPC::Generic::Serializer::JSON)],
	[qw(RPC::Generic::Serializer::StorableN)],
	[qw(RPC::Generic::Serializer::YAML_Any)]
);
my $tests_each = 4;

package TestRPC;
use Test::More;
plan tests => $tests_each * @serializers;

MOD: foreach my $serializer ( @serializers ){
	my $class = shift(@$serializer);

	use parent 'RPC::Generic';
	eval "require $class";
SKIP: {
	if( $class =~ /Dynamic([A-Z][a-z]+)([A-Z][a-z]+)/ ){
		# avoid 'redefinition errors'
		no strict 'refs';
		undef &{"${class}::". ($$serializer[$_] || $$_) } foreach 1 .. 2;
	}
	eval { $class->import(@$serializer) };
	skip("module $class failed import with: @$serializer", $tests_each) if $@;

	my $helper = substr($class, rindex($class, ':')+1);
	$helper .= ' + ' . $$serializer[0] if @$serializer;

	my $h = {hello => 'there', two => [1,2]};
	isa_ok($h, 'HASH', 'original');
	my $s = TestRPC->_serialize($h);
	is(ref($s), '', "serialized with $helper");
	my $d = TestRPC->_deserialize($s);
	isa_ok($d, 'HASH', "deserialized with $helper");
	is_deeply($h, $d, 'deserialized matches original');
}
}
