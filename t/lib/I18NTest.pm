package # Hide from PAUSE
    I18NTest;

use strict;
use warnings;
use DBICx::TestDatabase;

sub new {
    return DBICx::TestDatabase->new( 'I18NTest::Schema' );
}

1;

