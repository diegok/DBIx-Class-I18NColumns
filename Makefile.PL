use inc::Module::Install;

name 'DBIx-Class-I18NColumns';
all_from 'lib/DBIx/Class/I18NColumns.pm';

requires 'DBIx::Class';
requires 'DBIx::Class::ForceUTF8';
requires 'DBICx::TestDatabase';

test_requires 'Test::More' => '0.88';

auto_install;
WriteAll;

