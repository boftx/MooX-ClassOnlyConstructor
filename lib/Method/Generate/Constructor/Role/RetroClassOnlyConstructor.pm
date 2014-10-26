package Method::Generate::Constructor::Role::RetroClassOnlyConstructor;

# ABSTRACT: a role to make Moo constructors class-only methods.

use Moo::Role;
use Sub::Quote;

{
    $Method::Generate::Constructor::Role::RetroClassOnlyConstructor::VERSION = 'v0.1';
}

# since we can't break into it like the proposed patch, just replace it
around generate_method => sub {
  my $orig = shift;
  my ($self, $into, $name, $spec, $quote_opts) = @_;
  foreach my $no_init (grep !exists($spec->{$_}{init_arg}), keys %$spec) {
    $spec->{$no_init}{init_arg} = $no_init;
  }
  local $self->{captures} = {};

  # this is the only change that is made.
  my $body = qq{
    # Method::Generate::Constructor::Role::RetroClassOnlyConstructor
    require Carp;
    Carp::croak "'$into->$name' must be called as a class method"
      if ref(\$_[0]);

  };

  $body .= '    my $class = shift;'."\n"
          .'    $class = ref($class) if ref($class);'."\n";
  $body .= $self->_handle_subconstructor($into, $name);
  my $into_buildargs = $into->can('BUILDARGS');
  if ( $into_buildargs && $into_buildargs != \&Moo::Object::BUILDARGS ) {
      $body .= $self->_generate_args_via_buildargs;
  } else {
      $body .= $self->_generate_args;
  }
  $body .= $self->_check_required($spec);
  $body .= '    my $new = '.$self->construction_string.";\n";
  $body .= $self->_assign_new($spec);
  if ($into->can('BUILD')) {
    $body .= $self->buildall_generator->buildall_body_for(
      $into, '$new', '$args'
    );
  }
  $body .= '    return $new;'."\n";
  if ($into->can('DEMOLISH')) {
    require Method::Generate::DemolishAll;
    Method::Generate::DemolishAll->new->generate_method($into);
  }
  quote_sub
    "${into}::${name}" => $body,
    $self->{captures}, $quote_opts||{}
  ;
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
L<Method::Generate::Constructor/generate_method> with code that C<die>s
if the incoming C<$class> is a reference.

=head1 SEE ALSO

L<MooX::ClassOnlyConstructor>

=head2 STANDING ON THE SHOULDERS OF ...

This code would not exist without the examples in L<MooseX::StrictConstructor>
and the expert guidance of C<mst> and C<haarg>.

=head1 AUTHOR

Jim Bacon <jim@nortx.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Jim Bacon.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
