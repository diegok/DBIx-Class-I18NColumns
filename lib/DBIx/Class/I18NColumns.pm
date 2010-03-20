package DBIx::Class::I18NColumns;

use warnings;
use strict;
use base qw/DBIx::Class/;

our $VERSION = '0.01';

__PACKAGE__->mk_classdata('_i18n_columns');
__PACKAGE__->mk_group_accessors( 'simple' => qw/ language / );

sub add_i18n_columns {
    my $self    = shift;
    my @columns = @_;

    $self->_i18n_columns( {} ) unless defined $self->_i18n_columns();

    # Add columns & accessors
    while ( my $column = shift @columns ) {
        my $column_info = ref $columns[0] ? shift(@columns) : {};
        $column_info->{data_type} = lc( $column_info->{data_type} || 'varchar' ); 

        # Check column
        $self->throw_exception( "Cannot override existing column '$column' with this i18n one" )
            if ( $self->has_column($column) || exists $self->_i18n_columns->{$column} );

        $self->_i18n_columns->{$column} = $column_info;

        my $accessor = $column_info->{accessor} || $column;

        # Add accessor
        no strict 'refs';
        *{ $self . '::' . $accessor } = sub {
            my $self = shift;
            $self->_i18n_attr( $column => @_ );
        };
    }
}

sub _i18n_attr {
    my ( $self, $attr ) = ( shift, shift );
    
    my $language = ref $_[-1] ? pop->[0] : $self->language; 
    $self->throw_exception( "Cannot get or set an i18n column with no language defined" )
        unless $language;

    my $type_of_attr = $self->_i18n_columns->{$attr}{data_type};

    my $fk_column = 'id_' . $self->result_source->name;

    if ( my $value = shift ) {
        return $self->i18n_resultset->update_or_create(
            {   attr                   => $attr,
                $self->language_column => $language,
                $fk_column             => $self->id,
                $type_of_attr          => $value,
            }
        );
    }

    if (my $i18n_row = $self->i18n_resultset->find(
            {   attr                   => $attr,
                $self->language_column => $language,
                id_item                => $self->id,
            }
        )
        )
    {
        return $i18n_row->$type_of_attr;
    }

    return undef;
}

sub i18n_resultset {
    my $self = shift;

    my $i18n_rs_class = ( ref $self ) . 'I18N';
    my ($i18n_rs_name) = $i18n_rs_class =~ /([^:]+)$/;

    return $self->result_source->schema->resultset( $i18n_rs_name );
}

sub language_column { 'language' }

=head1 NAME

DBIx::Class::I18NColumns - Internationalization for DBIx::Class ResultSet'ss

=head1 VERSION

Version 0.01

=cut



=head1 SYNOPSIS


    use DBIx::Class::I18NColumns;

=head1 AUTHOR

Diego Kuperman, C<< <diego at freekeylabs.com > >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-dbix-class-i18ncolumns at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=DBIx-Class-I18NColumns>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc DBIx::Class::I18NColumns


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=DBIx-Class-I18NColumns>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/DBIx-Class-I18NColumns>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/DBIx-Class-I18NColumns>

=item * Search CPAN

L<http://search.cpan.org/dist/DBIx-Class-I18NColumns/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2010 Diego Kuperman.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of DBIx::Class::I18NColumns
