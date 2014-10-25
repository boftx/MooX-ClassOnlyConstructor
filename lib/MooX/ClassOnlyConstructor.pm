package MooX::ClassOnlyConstructor;

# ABSTRACT: Make Moo-based object constructors class-only methods

use strictures 1;

use Moo::Role ();
#use Class::Method::Modifiers qw(install_modifier);
 
use constant
    CON_ROLE => 'Method::Generate::Constructor::Role::ClassOnlyConstructor';
{
  $MooX::ClassOnlyContructor::VERSION = '0.001';
}
 
#
# The gist of this code was copied directly from HARTZELL's
# MooX::StrictConstructor and based on discussions with mst and
# others in #moose.
#
sub import {
    my $class  = shift;
    my $target = caller;
    unless ( $Moo::MAKERS{$target} && $Moo::MAKERS{$target}{is_class} ) {
        die "MooX::ClassOnlyConstructor can only be used on Moo classes.";
    }
 
    _apply_role($target);
 
#    install_modifier($target, 'after', 'extends', sub {
#        _apply_role($target);
#    });
}
 
sub _apply_role {
    my $target = shift;
    my $con = Moo->_constructor_maker_for($target);
    Moo::Role->apply_roles_to_object($con, CON_ROLE)
        unless Role::Tiny::does_role($con, CON_ROLE);
}

1;

__END__

