use strict;
use warnings;
use Test::More 'no_plan';
use utf8;

use lib 't/lib';
BEGIN { use_ok 'I18NTest' }

ok ( my $schema = I18NTest->new(), 'Create a schema object' );
isa_ok ( $schema, 'I18NTest::Schema');

ok ( my $item = $schema->resultset('Item')->create({
        name  => 'Diego Maradona',
    }), 'Create an item' 
);

ok ( $item->string( 'test in english', ['en'] ), "Set string in english" );
ok ( $item->string( 'test en español', ['es'] ), "Set string in spanish" );
is ( $item->string(['en']), 'test in english', 'English string is retrieved correctly');
is ( $item->string(['es']), 'test en español', 'Spanish string is retrieved correctly');
