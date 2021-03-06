#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 7;
use Mouse ();

my $role = Mouse::Meta::Role->create_anon_role(
    attributes => {
        is_worn => {
            is => 'rw',
            isa => 'Bool',
        },
    },
    methods => {
        remove => sub { shift->is_worn(0) },
    },
);

my $class = Mouse::Meta::Class->create('MyItem::Armor::Helmet');
$role->apply($class);
# XXX: Mouse::Util::apply_all_roles doesn't cope with references yet

my $visored = $class->construct_instance(is_worn => 0);
ok(!$visored->is_worn, "attribute, accessor was consumed");
$visored->is_worn(1);
ok($visored->is_worn, "accessor was consumed");
$visored->remove;
ok(!$visored->is_worn, "method was consumed");

like($role->name, qr/^Mouse::Meta::Role::__ANON__::SERIAL::\d+$/, "");
ok($role->is_anon_role, "the role knows it's anonymous");

ok(Class::MOP::is_class_loaded(Mouse::Meta::Role->create_anon_role->name), "creating an anonymous role satisifes is_class_loaded");
ok(Class::MOP::load_class(Mouse::Meta::Role->create_anon_role->name), "creating an anonymous role satisifes load_class");

