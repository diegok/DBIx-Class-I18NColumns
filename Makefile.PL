use inc::Module::Install;

name 'DBIx-Class-I18NColumns';
all_from 'lib/DBIx/Class/I18NColumns.pm';

requires 'parent';
requires 'DBIx::Class';
requires 'DBICx::TestDatabase' => '0.03';

test_requires 'Test::More' => '0.88';

auto_install;
WriteAll;

