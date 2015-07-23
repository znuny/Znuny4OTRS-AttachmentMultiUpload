# --
# Kernel/System/Znuny4OTRSAttachmentMultiUpload.pm - allows the upload of multiple attachments at once via redefining functions
# Copyright (C) 2001-2015 OTRS AG, http://otrs.com/
# Copyright (C) 2012-2015 Znuny GmbH, http://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --
## nofilter(TidyAll::Plugin::OTRS::Perl::PodChecker)

package Kernel::System::Znuny4OTRSAttachmentMultiUpload;

use strict;
use warnings;

our $ObjectManagerDisabled = 1;

# disable redefine warnings in this scope
{
    no warnings 'redefine';

=item Kernel::System::Web::Request::GetUploadAll()

gets file upload data.

    my %File = $ParamObject->Kernel::System::Web::Request::GetUploadAll(
        Param  => 'FileParam',  # the name of the request parameter containing the file data
        Source => 'string',     # 'string' or 'file', how the data is stored/returned, see below
    );

    returns (
        Filename    => 'abc.txt',
        ContentType => 'text/plain',
        Content     => 'Some text',
    );

    OR in case of a multi upload in file_upload or FileUpload fields:

    (
        Multiple => 3,
        1        => {
            Filename    => 'abc.txt',
            ContentType => 'text/plain',
            Content     => 'Some text',
        },
        2        => {
            Filename    => 'abc.txt',
            ContentType => 'text/plain',
            Content     => 'Some text',
        },
        3        => {
            Filename    => 'abc.txt',
            ContentType => 'text/plain',
            Content     => 'Some text',
        },
    );

    If you send Source => 'string', the data will be returned directly in
    the return value ('Content'). If you send 'file' instead, the data
    will be stored in a file and 'Content' will just return the file name.

=cut

    sub Kernel::System::Web::Request::GetUploadAll {
        my ( $Self, %Param ) = @_;
        my $EncodeObject = $Kernel::OM->Get('Kernel::System::Encode');

        # get upload
        my @Upload = $Self->{Query}->upload( $Param{Param} );
        return if !scalar @Upload;

        my $Multiple = 0;
        if (
            scalar @Upload > 1
            && grep { $Param{Param} eq $_ } qw( file_upload FileUpload )
            )
        {
            $Multiple = 1;
        }

        my @Attachments = $Self->GetArray(
            Param => $Param{Param},
            Raw   => 1
        );
        if ( !scalar @Attachments ) {
            @Attachments = ('unknown');
        }

        my %ReturnData;
        my $AttachmentCounter = 0;
        ATTACHMENT:
        for my $Attachment (@Attachments) {

            my $NewFileName = "$Attachment";    # use "" to get filename of anony. object

            $EncodeObject->EncodeInput( \$NewFileName );

            # replace all devices like c: or d: and dirs for IE!
            $NewFileName =~ s/.:\\(.*)/$1/g;
            $NewFileName =~ s/.*\\(.+?)/$1/g;

            # return a string
            my $Content;
            while (<$Attachment>) {
                $Content .= $_;
            }
            close $Attachment;

            # Check if content is there, IE is always sending file uploads without content.
            return if !$Content && !$Multiple;
            next ATTACHMENT if !$Content;

            my $ContentType = $Self->_GetUploadInfo(
                Filename => $Attachment,
                Header   => 'Content-Type',
            );

            my %UploadData = (
                Filename    => $NewFileName,
                Content     => $Content,
                ContentType => $ContentType,
            );

            return %UploadData if !$Multiple;

            $AttachmentCounter++;

            $ReturnData{$AttachmentCounter} = \%UploadData;
        }

        $ReturnData{Multiple} = $AttachmentCounter;

        return %ReturnData;
    }

    # reset all warnings
}

1;
