# --
# Kernel/Output/HTML/OutputFilterPostZnuny4OTRSAttachmentMultiUpload.pm - adds multiple="multiple" to input file_upload and FileUpload fields
# Copyright (C) 2014 Znuny GmbH, http://znuny.com/
# --

package Kernel::Output::HTML::OutputFilterPostZnuny4OTRSAttachmentMultiUpload;

use strict;
use warnings;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    return if !defined $Param{Data};

    ${ $Param{Data} } =~ s{
        (<input[^>]+name="(?:FileUpload|file_upload)"[^>]+)((?:\/)?>)
    }
    {
        my $Start = $1;
        my $End   = $2;
        if ( $Start !~ /multiple/i ) {
            $Start . ' multiple="multiple"' . $End;
        }
        else {
           $Start . $End;
        }
    }sgxime;

    return 1;
}

1;
