package Solaris::Disk::SVM::Graph;

use strict;
use warnings;
use Carp;
use vars qw($AUTOLOAD %_properties);
use Solaris::Disk::SVM;
use GraphViz;

our $VERSION = '0.02';

=head1 NAME

Solaris::Disk::SVM::Graph - Graph your Solaris Volume Manager configurations

=head1 SYNOPSIS

    my $graph = Solaris::Disk::SVM::Graph->new(
        sourcedir => 'path/to/dir',     # path to SVM config files,
                                        # see Solaris::Disk::SVM for details
        fontname => 'fontname',
        fontsize => 'fontsize',
    );

    $graph->output();                   # output the whole SVM config to svm.png

    # output whole configuration
    $graph->output( 
        output    => '/path/to/image.svg',
                                        # format deduced from file name, if format
                                        # is not present
        format => 'png',                # or anything accepted by GraphViz,
                                        # extension will be appended to output filename
    );

    # output one device
    $graph->output( objects => 'd10' );  # d10 object with sub-devices to d10.png

    # output many devices on same graph
    $graph->output( objects => [ 'd10', 'd11' ] );

    # output one device specifying output file name & format
    $graph->output(
        objects => 'd10'
        output  => '/path/to/image.svg',
        format  => 'png',
    );


=head1 FUNCTIONS

=over 

=item *
new

The C<new> method loads the SVM configuration using
L<Solaris::Disk::SVM>.

The C<new> method accepts the following named parameters:

=over 4

=item *
sourcedir

See L<Solaris::Disk::SVM>. The source directory when using a predumped
disk configuration to graph.

=item *
fontname

Font name to use.

=item *
fontsize

Font size to use.

=back

=cut

use constant {
        DEFAULT   => 0,
        VALIDATE  => 1,
        TRANSFORM => 2,
};

sub _isformat($) 
{
    my $arg = lc shift;
    my %allowedformats =
      map { $_ => 1 }
      qw( dot canon text ps hpgl pcl mif pic gd gd2 gif jpeg png wbmp cmap ismap imap vrml vtx mp fig svg plain);

    return 1 if defined $allowedformats{$arg};
    0;
}

#                 DEFAULT, VALIDATE, TRANSFORM
%_properties = (
    sourcedir   => [ undef,       undef, undef ],
    fontname    => [ 'helvetica', undef, undef ],
    fontsize    => [ 9,           undef, undef ],
    width       => [ undef,       undef, undef ],
    height       => [ undef,       undef, undef ],
    format      => [ 'png',       \&_isformat, sub { my $v=shift; lc $v} ],
    orientation => [ 0,           undef, sub { my $v=shift; $v ? 1 : 0; } ],
);

sub _checkparams ($$@)
{
    my %parms;
    my ( $self, $arglist, @args ) = @_;

    my $i = 0;
    my $re = join "|", @$arglist;
    $re = qr/^(?:$re)$/;
    while ( $i < @args ) {
        if ( $args[$i] =~ $re ) {
            my ( $k, $v ) = splice( @args, $i, 2 );
            $parms{$k} = $v;
        }
        else {
            $i++;
        }
    }
    # shouldn't be anything left in # @args
    warn "Unknown parameter(s): @args" if @args;

    %parms;
}

sub _setdefaults ($)
{
    my ( $self, @args ) = @_;
    $self->{$_} = $_properties{$_}[DEFAULT]
      foreach ( keys %_properties );
}

sub new {
    my ( $old, @args ) = @_;

    my $class = ref($old) || $old;

    if (! defined $class ) {
        croak 'not a class';
        return undef;
    }
    my $self = bless {}, $class;

    my %parms = $self->_checkparams( [ keys %_properties ], @args);


    if (ref $old) {
        %$self = %$old;
    }
    else {
        $self->{svm} = Solaris::Disk::SVM->new(
            init => 1,
            defined( $parms{sourcedir} )
            ? ( 'sourcedir' => $parms{sourcedir} )
            : (),
        );

        $self->_setdefaults;
#        $self->{$_} = $_properties{$_}[DEFAULT]
#          foreach ( keys %_properties );
          
        $self->{$_} = $parms{$_}
          foreach ( keys %parms );

        #map { $self->{$_} = $parms{$_} } keys %parms;

    }
    $self;
}

=item *
output

The C<output> method accepts the following named parameters:

=over 4

=item * output:

name of the file to output.  This filename may have a significant
extension to GraphViz (see below)

Default: F<svm.png>

=item * format:

File format of the graphic, as accepted by GraphViz. This adds an
extension to the output file name.

Default: png

=item * objects: 

If specified, only graph the specified SVM objects.

Objects may be a scalar (containing the name), or a reference to an
array, containing the objects names.

Default: graph all objects.

=item * orientation: 

Graph orientation. See C<rankdir> in L<GraphViz>

    0 => horizontal juxtaposition of verticaly oriented graphs.
    1 => vertical juxtaposition of horizontaly oriented graphs.

=item * width: 

Page width, in inches (the default unit of graphviz).

=item * height: 

Page height, in inches (the default unit of graphviz).

=back

=cut

sub output {
    my ( $self, @args ) = @_;

    my %parms = $self->_checkparams( [ qw(output format objects
        orientation width height) ], @args);

    my $imagename = $parms{output} || 'svm.png';
    my $imagetype = lc substr( $imagename, 1 + rindex( $imagename, "." ) );
    my @objects;
    if (defined $parms{objects} ) {
        my $objects = $parms{objects};
        @objects = ref $objects eq 'ARRAY' ? @{$objects} : $objects;
    }

    # format parameter override filename
    my $format = $self->format;
    if ( defined($parms{format}) &&
        _isformat( $parms{format} )) {
        $imagetype = $parms{format};
        $imagename .= '.'. $parms{format};
    }

    if (! _isformat $imagetype ) {
        warn "Format <$imagetype> not doable by GraphViz";
        return undef;
    }

    my $width  = defined $parms{width} ? $parms{width} : $self->{width};
    my $height = defined $parms{height} ? $parms{height} : $self->{height};
    my $orientation = defined $parms{orientation} ? $parms{orientation} : $self->{orientation};
    
    my $g = GraphViz->new(
        directed   => 0,        # not interesting to change it
        layout     => 'dot',    # idem
        overlap    => 'false',  # idem
        rankdir    => $orientation,
        (defined $width)    ? (pagewidth  => $width) : (),
        (defined $height)   ? (pageheight => $height) : (),
        node       => {
            fontname => $self->fontname,
            fontsize => $self->fontsize,
            shape    => 'ellipse',
        }
    );

    my $svm = $self->{svm};
    my %devs2graph;
    my %linkto;

    if ( @objects ) {
        $devs2graph{$_}++
            foreach (@objects);
    }
    else {
        %devs2graph = map { $_ => 1 } keys %{ $svm->{devices} };
    }

    foreach my $dev ( keys %devs2graph ) {
        $devs2graph{$_}++ for ($svm->getsubdevs($dev));
    }
    my %pdevs2graph;

    foreach my $dev ( keys %devs2graph ) {
        my $size  = $svm->size($dev) >> 11;
        my $label = "$dev\n" . $svm->{devices}{$dev}{type} . "\n($size Mo)";
        my ( @rank, @shape ) = (), ();

        if ( defined( $svm->{mnttab}{dev2mp}{$dev} ) ) {
            $label = $svm->{mnttab}{dev2mp}{$dev} . "\n$label";
            @rank = ( rank => 'mountpoint' );
        }
        if ( $svm->{devices}{$dev}{type} eq 'softpart' ) {
            @rank  = ( rank  => 'softpart' );
            @shape = ( shape => 'parallelogram' );
        }
        $g->add_node( $dev, label => $label, @rank, @shape,);

        # Physical device associés
        if ( scalar keys %{ $svm->{LeafPhysDevices}{$dev} } != 0 ) {
            foreach my $pdev ( keys %{ $svm->{LeafPhysDevices}{$dev} } ) {
                my $size = $svm->size($pdev) >> 11;
                $g->add_node( $pdev, label => "$pdev\n$size Mo", shape => 'box',
                                    rank  => 'physical' );
                $g->add_edge( $dev   => $pdev, arrowhead => 'normal');

            }
        }
    }

    foreach my $object ( keys %devs2graph ) {
        for ( @{ $svm->{SubElements}{$object} } ) {
            $g->add_edge( $object   => $_, arrowhead => 'normal');
        }
    }

    foreach my $parent ( keys %linkto ) {
        foreach my $sub ( @{$linkto{$parent}} ) {
        }
    }

    my $outputmethod = "as_$imagetype";
    $g->$outputmethod($imagename);

    $imagename;
}

=item *
Accessors

=cut

sub AUTOLOAD {
    my $self = shift;
    my $attr = $AUTOLOAD;
    $attr =~ s/.*:://;
    return unless $attr =~ /[^A-Z]/;    # skip DESTROY and all-cap methods

    if (! $_properties{$attr}) {
        croak "invalid accessor $attr()";
    }

    if (@_) {
        my $value = shift;

        if (defined $_properties{$attr}[TRANSFORM]) {
            $value = $_properties{$attr}[TRANSFORM]( $value ) ;
        }

        if (defined $_properties{$attr}[VALIDATE]) {
            if ( $_properties{$attr}[VALIDATE]( $value ) ) {
                $self->{$attr} = $value;
            } else {
                croak "'$value' cannot be validated for attribute '$attr'";
            }
        }
        else {
            $self->{$attr} = $value;
        }
    }

    if (! defined $self->{$attr} ) {
        $self->{$attr} = $_properties{$attr}[DEFAULT];
    }

    $self->{$attr};
}

=item *
version

Returns the module version

=cut

sub version { $VERSION }

1;

__END__

=back

=head1 AUTHOR

Jérôme Fenal <jfenal@free.fr>

=head1 WEBSITE

Head to L<http://jfenal.free.fr/Solaris/> to see some sample graphics.

=head1 VERSION

This is version 0.02 of the L<Solaris::Disk::SVM::Graph> script.

=head1 COPYRIGHT

Copyright (C) 2004, 2005 Jérôme Fenal. All Rights Reserved

This module is free software; you can redistribute it and/or modify it under the
same terms as Perl itself.

=head1 SEE ALSO

=over

=item *
L<Solaris::Disk::SVM>

is used to retrieve information about the SVM configuration.

=item *
L<Solaris::Disk::VTOC>

is used to get raw disk partitions.

=item *
L<Solaris::Disk::Mnttab>

is used to get current mounted devices.

=item *
the SDS / SVM manual pages:

L<metastat(1M)>, L<metatool(1M)>, etc.

=back
