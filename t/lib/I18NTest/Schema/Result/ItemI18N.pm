package 
    I18NTest::Schema::Result::ItemI18N;

use strict;
use warnings;
use parent 'DBIx::Class';

__PACKAGE__->load_components( qw/ ForceUTF8 Core / );

__PACKAGE__->table( 'item_i18n' );
__PACKAGE__->add_columns(
    'id_item',
    { data_type => 'INT', default_value => 0, is_nullable => 0 },
    'language',
    { data_type => 'VARCHAR', default_value => '', is_nullable => 0, size => 2 },
    'attr',
    { data_type => 'VARCHAR', is_nullable => 0, size => 32 },
    'varchar',
    { data_type => 'VARCHAR', is_nullable => 1, size => 255 },
    'text',
    { data_type => 'TEXT', is_nullable => 1 },
);

__PACKAGE__->set_primary_key("id_item", "language", "attr");
__PACKAGE__->belongs_to("id_item", "I18NTest::Schema::Result::Item", { id => "id_item" });

1;
