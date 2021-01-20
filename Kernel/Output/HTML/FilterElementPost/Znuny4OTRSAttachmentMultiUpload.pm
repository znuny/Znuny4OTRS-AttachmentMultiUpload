# --
# Copyright (C) 2012-2021 Znuny GmbH, http://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::FilterElementPost::Znuny4OTRSAttachmentMultiUpload;

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
        (<input[^>]+name="(?:FileUpload|file_upload)"[^>]+)>
    }
    {
        my $Start = $1;
        my $End   = '/>';

        $Start =~ s{/\z}{};

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
