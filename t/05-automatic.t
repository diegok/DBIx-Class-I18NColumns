use strict;
use warnings;
use Test::More 'no_plan';
use utf8;

use lib 't/lib';
BEGIN { use_ok 'I18NTest' }

ok ( my $schema = I18NTest->new('I18NTest::SchemaAuto'), 'Create a schema object' );
isa_ok ( $schema, 'I18NTest::SchemaAuto');

ok ( my $item_rs = $schema->resultset('Item') );

{ 
    ok ( my $item = $item_rs->create({
            name  => 'Diego Maradona',
            string => 'futbol futbol futbol',
            text => 'santa maradona... la la la',
            language => 'es',
        }), 'Create an item' 
    );

    ok ( my $item_id = $item->id, 'Item has ID' );

    ok ( $item->language('en'), 'Switch to english' );
    ok ( ! $item->string, 'string not set, yet!');
    ok ( $item->string( 'test in english' ), "Set string in english" );
    ok ( $item->text( 'text in english' ), "Set text in english" );
    ok ( $item->update, "Call update" );

    is ( $item->string, 'test in english', 'English string is set ok');
    is ( $item->string(['es']), 'futbol futbol futbol', 'Spanish string is ok forcing lang');
}

{
    ok ( my $item = $item_rs->search({ language => 'en' })->single, 'Single item retrieved' );
    is ( $item->string, 'test in english', 'English string is set ok');
    is ( $item->string(['es']), 'futbol futbol futbol', 'Spanish string is ok forcing lang');

    ok ( my @i18n_rows = $item->i18n_rows->all, 'Auto-created relation to auto-created RS exists' );
    is ( scalar(@i18n_rows), 2, 'Relation to i18n rows returned two rows' );
}
