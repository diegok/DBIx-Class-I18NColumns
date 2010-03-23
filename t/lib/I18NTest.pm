package # Hide from PAUSE
    I18NTest;

use strict;
use warnings;
use DBICx::TestDatabase;

sub new {
    my ( $class, $schema_class ) = @_;
    return DBICx::TestDatabase->new( $schema_class || 'I18NTest::Schema' );
}

1;

