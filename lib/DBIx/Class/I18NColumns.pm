package DBIx::Class::I18NColumns;

use warnings;
use strict;
use base qw/DBIx::Class/;

our $VERSION = '0.01';

__PACKAGE__->mk_classdata('_i18n_columns');
__PACKAGE__->mk_group_accessors( 'simple' => qw/ language _i18n_column_data / );

sub add_i18n_columns {
    my $self    = shift;
    my @columns = @_;

    $self->_i18n_columns( {} ) unless defined $self->_i18n_columns();
#    $self->_i18n_column_data( {} ) unless defined $self->_i18n_column_data();

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
            $self->_i18n_method( $column => @_ );
        };
    }
}

sub _i18n_method {
    my ( $self, $column ) = ( shift, shift );
    
    my $old_language = $self->language;
    $self->language(pop->[0]) if scalar @_ && ref $_[-1]; 

    $self->throw_exception( "Cannot get or set an i18n column with no language defined" )
        unless $self->language;

    my $ret;
    if ( my $value = shift ) {
        $ret = $self->set_column( $column => $value );
    }
    else {
        $ret = $self->get_column( $column );
    }

    $self->language($old_language);

    return $ret; 
}

sub foreign_column { 'id_' . shift->result_source->name }

sub i18n_resultset {
    my $self = shift;

    my $i18n_rs_class = ( ref $self ) . 'I18N';
    my ($i18n_rs_name) = $i18n_rs_class =~ /([^:]+)$/;

    return $self->result_source->schema->resultset( $i18n_rs_name );
}

sub language_column { 'language' }

=head2 has_any_column

Returns true if the source has a i18n or regular column of this name, 
false otherwise.

=cut

sub has_any_column {
    my ( $self, $column ) = ( shift, shift );
    return ( $self->has_i18n_column($column) || $self->has_column($column) )
        ? 1
        : 0;
}

=head2 has_i18n_column

Returns true if the source has a i18n column of this name, false otherwise.

=cut

sub has_i18n_column {
    my ( $self, $column ) = ( shift, shift );
    return ( exists $self->_i18n_columns->{$column} ) ? 1 : 0;
}

sub set_column {
    my ( $self, $column, $value ) = @_;

    if ( $self->has_i18n_column($column) ) {
        #TODO: do I need to make it dirty?
        return $self->store_column( $column => $value );
    }

    return $self->next::method( $column, $value );
}

sub store_column {
    my ( $self, $column, $value ) = @_;

    $self->_i18n_column_data({}) unless $self->_i18n_column_data;
    $self->_i18n_column_data->{$column} = {} unless exists $self->_i18n_column_data->{$column};

    if ( $self->has_i18n_column($column) ) {
        my $type = $self->_i18n_columns->{$column}{data_type};
        if ( exists $self->_i18n_column_data->{$column}{ $self->language} ) {
            return $self->_i18n_column_data->{$column}{ $self->language }
                ->$type($value);
        }
        else {
            return $self->_i18n_column_data->{$column}{ $self->language }
                = $self->i18n_resultset->new({   
                    $type                  => $value,
                    $self->language_column => $self->language,
                    $self->foreign_column  => $self->id,
                    attr                   => $column,
                });
        }
    }

    return $self->next::method( $column, $value );
}

sub get_column {
    my ( $self, $column ) = ( shift, shift );
    my $lang = $self->language;

    $self->_i18n_column_data({}) unless $self->_i18n_column_data;
    $self->_i18n_column_data->{$column} = {} unless exists $self->_i18n_column_data->{$column};

    if ( $self->has_i18n_column($column) ) {
        unless ( exists $self->_i18n_column_data->{$column}{$lang} ) {
            $self->_i18n_column_data->{$column}{$lang} = 
                $self->i18n_resultset->find_or_new({   
                    attr                   => $column,
                    $self->language_column => $self->language,
                    $self->foreign_column  => $self->id,
            });
        }

        my $type = $self->_i18n_columns->{$column}{data_type};
        return $self->_i18n_column_data->{$column}{$lang}->$type;
    }

    return $self->next::method( $column, @_ );
}

sub update {
    my $self = shift;

    $self->next::method( @_ );

    if ( $self->_i18n_column_data ) {
        for my $column ( keys %{$self->_i18n_column_data} ) {
            for my $lang ( keys %{$self->_i18n_column_data->{$column}} ) {
                my $i18n_row = $self->_i18n_column_data->{$column}{$lang};
                $i18n_row->in_storage ? $i18n_row->update : $i18n_row->insert ;
            }
        }
    }

    return $self;
}

=head1 NAME

DBIx::Class::I18NColumns - Internationalization for DBIx::Class Result class

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
