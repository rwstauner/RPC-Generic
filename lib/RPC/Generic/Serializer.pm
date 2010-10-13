package RPC::Generic::Serializer;
# ABSTRACT: Base class for Serializers; exports _serialize() and _deserialize()
use strict;
use warnings;

=head1 SYNOPSIS

This is a base class for Serializers to use with L<RPC::Generic|RPC::Generic>.

It exports methods named C<_serialize()> and C<_deserialize()>.
It is intended to be C<use>d from a base class of L<RPC::Generic|RPC::Generic>
which expects methods by those names.

	package MyRPC::Serializer;
	use parent 'RPC::Generic::Serializer;

	sub _serialze { obj_to_string($_[1]); }
	sub _deserialze { string_to_obj($_[1]); }

	package MyRPC;
	use parent 'RPC::Generic';
	use MyRPC::Serializer;

The default C<_serialize()> and C<_deserialize()> methods
defined in this base class are fairly useless.
This way no dependencies are required by this module.

See example (slightly more useful) Serializers
included in this package: F<RPC/Generic/Serializer/*.pm>,
or feel free to write your own.

This base class also includes some functions useful for creating subclasses...
see L</FUNCTIONS>.

=head1 FUNCTIONS

=over

=item copy_methods_to_namespace EXPR

Copies the C<_serialize()> and C<_deserialize()>
methods into the I<EXPR> namespace.

=cut

sub copy_methods_to_namespace {
	my ($class, $namespace) = @_;
	local $_;
	no strict 'refs';
	*{"${namespace}::$_"} = *{"${class}::$_"} foreach qw(_serialize _deserialize);
}

=item import
	
Exports C<_serialize()> and C<_deserialize()> to caller's namespace.

=cut

sub import {
	my $class = shift;
	my $caller = caller(); # the package "use"ing this module
	$class->copy_methods_to_namespace($caller);
}

=item require_module EXPR

Require the specified module and return the module name
so the call can be chained with an C<import()> for ease of [re]use:

	$class->require_module($module)->import(@args);

Useful from the C<import()> function of a subclass to allow a construct like:

	use RPC::Generic::Serializer::subclass qw(Other::Module import args);

See examples of this usage in the included "Dynamic" Serializers:
F<RPC/Generic/Serializer/Dynamic*.pm>

=cut

sub require_module {
	my ($class, $module) = @_;
	eval "require $module";
	die($@) if $@;
	return $module;
}

=item _serialize EXPR

Serialize EXPR into a common format.

Subclasses should overwrite this method
as the default is fairly useless (merely stringify).

This method will be exported to the caller's namespace
and called as an object method: C<< $rpc->_serialize($obj) >>

=cut

sub _serialize {
	# just stringify (not useful... this should be overwritten by subclasses)
	return "$_[1]";
}

=item _deserialize EXPR

Deserialize EXPR from the common format into a data structure.

Subclasses should overwrite this method
as the default is fairly useless (return a reference to EXPR).

This method will be exported to the caller's namespace
and called as an object method: C<< $rpc->_deserialize($obj) >>

=cut

sub _deserialize {
	# most deserializers will return a reference, so be consistent
	return \$_[1];
}

=back

=cut

1;
