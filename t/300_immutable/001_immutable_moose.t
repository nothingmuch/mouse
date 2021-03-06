#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 15;
use Test::Exception;

use Mouse::Meta::Role;


{
    package FooRole;
    our $VERSION = '0.01';
    sub foo {'FooRole::foo'}
}

{
    package Foo;
    use Mouse;

    #two checks because the inlined methods are different when
    #there is a TC present.
    has 'foos' => ( is => 'ro', lazy_build => 1 );
    has 'bars' => ( isa => 'Str', is => 'ro', lazy_build => 1 );
    has 'bazes' => ( isa => 'Str', is => 'ro', builder => '_build_bazes' );
    sub _build_foos  {"many foos"}
    sub _build_bars  {"many bars"}
    sub _build_bazes {"many bazes"}
}

{
    my $foo_role = Mouse::Meta::Role->initialize('FooRole');
    my $meta     = Foo->meta;

    lives_ok { Foo->new } "lazy_build works";
    is( Foo->new->foos, 'many foos',
        "correct value for 'foos'  before inlining constructor" );
    is( Foo->new->bars, 'many bars',
        "correct value for 'bars'  before inlining constructor" );
    is( Foo->new->bazes, 'many bazes',
        "correct value for 'bazes' before inlining constructor" );
    lives_ok { $meta->make_immutable } "Foo is imutable";
    SKIP: {
        skip "Mouse doesn't supports ->identifier, add_role", 2;
        lives_ok { $meta->identifier } "->identifier on metaclass lives";
        dies_ok { $meta->add_role($foo_role) } "Add Role is locked";
    };
    lives_ok { Foo->new } "Inlined constructor works with lazy_build";
    is( Foo->new->foos, 'many foos',
        "correct value for 'foos'  after inlining constructor" );
    is( Foo->new->bars, 'many bars',
        "correct value for 'bars'  after inlining constructor" );
    is( Foo->new->bazes, 'many bazes',
        "correct value for 'bazes' after inlining constructor" );
    SKIP: {
        skip "Mouse doesn't supports make_mutable", 2;
        lives_ok { $meta->make_mutable } "Foo is mutable";
        lives_ok { $meta->add_role($foo_role) } "Add Role is unlocked";
    };

}

{
  package Bar;

  use Mouse;

  sub BUILD { 'bar' }
}

{
  package Baz;

  use Mouse;

  extends 'Bar';

  sub BUILD { 'baz' }
}

lives_ok { Bar->meta->make_immutable }
  'Immutable meta with single BUILD';

lives_ok { Baz->meta->make_immutable }
  'Immutable meta with multiple BUILDs';

=pod

Nothing here yet, but soon :)

=cut
