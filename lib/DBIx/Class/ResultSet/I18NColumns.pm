package DBIx::Class::ResultSet::I18NColumns;

use warnings;
use strict;
use base qw/ DBIx::Class::ResultSet /; 

__PACKAGE__->mk_group_accessors( 'simple' => qw/ language / );

sub find {
    my $self = shift;
    my $row = $self->next::method( $self->_extract_lang(@_) );
    if ( $row && $self->language ) {
        $row->language( $self->language );
    }
    return $row;
}

sub search {
    my $self = shift;
    my $rs = $self->next::method( $self->_extract_lang(@_) );
    if ( $rs && $self->language ) {
        $rs->language( $self->language );
    }
    return $rs;
}

sub single {
    my $self = shift;
    my $row = $self->next::method( $self->_extract_lang(@_) );
    if ( $row && $self->language ) {
        $row->language( $self->language );
    }
    return $row;
}

sub next {
    my $self = shift;
    my $row = $self->next::method( @_ );
    if ( $row && $self->language ) {
        $row->language( $self->language );
    }
    return $row;
}

sub language_column { 'language' }

sub _extract_lang {
    my $self = shift;
    my @args = @_;

    if ( ( ref $args[0] eq 'HASH' ) && ( my $lang = delete $args[0]->{ $self->language_column } ) ) {
        $self->language($lang);
    }

    return @args;
}

=head1 NAME

DBIx::Class::ResultSet::I18NColumns - Internationalization for DBIx::Class ResultSet class

=head1 DESCRIPTION

See L<DBIx::Class::I18NColumns>

=head1 AUTHOR

Diego Kuperman, C<< <diego at freekeylabs.com > >>

=head1 COPYRIGHT & LICENSE

Copyright 2010 Diego Kuperman.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1; # End of DBIx::Class::ResultSet::I18NColumns
