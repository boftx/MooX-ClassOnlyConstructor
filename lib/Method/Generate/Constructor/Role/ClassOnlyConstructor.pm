package Method::Generate::Constructor::Role::ClassOnlyConstructor;

# ABSTRACT: a role to make Moo constructors class-only methods.

use Moo::Role;

{
    $Method::Generate::Constructor::Role::ClassOnlyConstructor::VERSION = 'v0.1';
}

#
# The gist of this code was copied directly from Dave Rolsky's (DROLSKY)
# MooseX::StrictConstructor, specifically from
# MooseX::StrictConstructor::Trait::Method::Constructor as a modifier around
# _generate_BUILDALL.  It has diverged only slightly to handle Moo-specific
# differences.
#
around _generate_constructor => sub {
    my $orig = shift;
    my $self = shift;

    my ( $into, $name, $spec ) = @_;
    foreach my $no_init ( grep !exists( $spec->{$_}{init_arg} ), keys %$spec ) {
        $spec->{$no_init}{init_arg} = $no_init;
    }

    my $body = '    my $class = shift;' . "\n";

    $body .= qq{
    # Method::Generate::Constructor::Role::ClassOnlyConstructor
    require Carp;
    Carp::croak "'$into->$name' must be called as a class method only"
      if ref(\$class);

    };

    $body .= $self->_handle_subconstructor( $into, $name );
    my $into_buildargs = $into->can('BUILDARGS');
    if ( $into_buildargs && $into_buildargs != \&Moo::Object::BUILDARGS ) {
        $body .= $self->_generate_args_via_buildargs;
    }
    else {
        $body .= $self->_generate_args;
    }
    $body .= $self->_check_required($spec);
    $body .= '    my $new = ' . $self->construction_string . ";\n";
    $body .= $self->_assign_new($spec);
    if ( $into->can('BUILD') ) {
        $body .= $self->buildall_generator->buildall_body_for( $into, '$new',
            '$args' );
    }
    $body .= '    return $new;' . "\n";
    if ( $into->can('DEMOLISH') ) {
        require Method::Generate::DemolishAll;
        Method::Generate::DemolishAll->new->generate_method($into);
    }
    return $body;
};

1;

__END__

=pod

=head1 NAME

Method::Generate::Constructor::Role::ClassOnlyConstructor - a role to make Moo constructors class only.

=head1 VERSION

version 0.001

=head1 DESCRIPTION

This role effectively replaces
L<Method::Generate::Constructor/_generate_constructor> with code that C<die>s
if C<$class> is a reference.

=head2 STANDING ON THE SHOULDERS OF ...

This code would not exist without the examples in L<MooseX::StrictConstructor>
and the expert guidance of C<mst>.

=head1 AUTHOR

Jim Bacon <jim@nortx.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Jim Bacon.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
