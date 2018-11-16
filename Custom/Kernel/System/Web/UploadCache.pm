# --
# Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2018 Znuny GmbH, http://znuny.com/
# --
# $origin: otrs - 5a8c531f122fbf9019cc08e5b2965a2f2ba0e469 - Kernel/System/Web/UploadCache.pm
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Kernel::System::Web::UploadCache;

use strict;
use warnings;

# ---
# Znuny4OTRS-AttachmentMultiUpload
# ---
# our @ObjectDependencies = (
#     'Kernel::Config',
# );
#
our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::Log',
);
# ---

=head1 NAME

Kernel::System::Web::UploadCache - an upload file system cache

=head1 SYNOPSIS

All upload cache functions.

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create an object. Do not use it directly, instead use:

    use Kernel::System::ObjectManager;
    local $Kernel::OM = Kernel::System::ObjectManager->new();
    my $WebUploadCacheObject = $Kernel::OM->Get('Kernel::System::Web::UploadCache');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    my $GenericModule = $Kernel::OM->Get('Kernel::Config')->Get('WebUploadCacheModule')
        || 'Kernel::System::Web::UploadCache::DB';

    # load generator auth module
    $Self->{Backend} = $Kernel::OM->Get($GenericModule);

    return $Self if $Self->{Backend};
    return;
}

=item FormIDCreate()

create a new Form ID

    my $FormID = $UploadCacheObject->FormIDCreate();

=cut

sub FormIDCreate {
    my $Self = shift;

    return $Self->{Backend}->FormIDCreate(@_);
}

=item FormIDRemove()

remove all data for a provided Form ID

    $UploadCacheObject->FormIDRemove( FormID => 123456 );

=cut

sub FormIDRemove {
    my $Self = shift;

    return $Self->{Backend}->FormIDRemove(@_);
}

=item FormIDAddFile()

add a file to a Form ID

    $UploadCacheObject->FormIDAddFile(
        FormID      => 12345,
        Filename    => 'somefile.html',
        Content     => $FileInString,
        ContentType => 'text/html',
        Disposition => 'inline', # optional
    );

ContentID is optional (automatically generated if not given on disposition = inline)

    $UploadCacheObject->FormIDAddFile(
        FormID      => 12345,
        Filename    => 'somefile.html',
        Content     => $FileInString,
        ContentID   => 'some_id@example.com',
        ContentType => 'text/html',
        Disposition => 'inline', # optional
    );
# ---
# Znuny4OTRS-AttachmentMultiUpload
# ---
Multiple files can be uploaded via the 'Multiple' paramter

    $UploadCacheObject->FormIDAddFile(
        FormID      => 12345,
        Multiple    => 3,
        1           => {
            Filename    => 'somefile.html',
            Content     => $FileInString,
            ContentType => 'text/html',
            Disposition => 'inline', # optional
        },
        2           => {
            Filename    => 'somefile.html',
            Content     => $FileInString,
            ContentType => 'text/html',
            Disposition => 'inline', # optional
        },
        3           => {
            Filename    => 'somefile.html',
            Content     => $FileInString,
            ContentType => 'text/html',
            Disposition => 'inline', # optional
        }
    );
# ---
=cut

sub FormIDAddFile {
# ---
# Znuny4OTRS-AttachmentMultiUpload
# ---
#    my $Self = shift;
#
#    return $Self->{Backend}->FormIDAddFile(@_);
    my ( $Self, %Param ) = @_;

    # fallback behavior if no 'Multiple' parameter is given
    if ( !$Param{Multiple} ) {
        return $Self->{Backend}->FormIDAddFile(%Param);
    }
    else {

        # otherwise we got a multi upload so we need to check
        # how many files were uploaded and loop over each of them
        # to add it to the form
        for my $UploadID ( 1 .. $Param{Multiple} ) {
            my $Added = $Self->{Backend}->FormIDAddFile(
                FormID => $Param{FormID},
                %{ $Param{$UploadID} },
            );

            # in case of an error, log it but keep loading files up
            if ( !$Added ) {
                my $AttachmentName = $Param{$UploadID}->{Filename};

                $Kernel::OM->Get('Kernel::System::Log')->Log(
                    Priority => 'error',
                    Message  => "Error while adding attachment '$AttachmentName' to form with FormID '$Param{FormID}'."
                );
            }
        }

        return 1;
    }
# ---
}

=item FormIDRemoveFile()

removes a file from a form id

    $UploadCacheObject->FormIDRemoveFile(
        FormID => 12345,
        FileID => 1,
    );

=cut

sub FormIDRemoveFile {
    my $Self = shift;

    return $Self->{Backend}->FormIDRemoveFile(@_);
}

=item FormIDGetAllFilesData()

returns an array with a hash ref of all files for a Form ID

    my @Data = $UploadCacheObject->FormIDGetAllFilesData(
        FormID => 12345,
    );

    Return data of on hash is Content, ContentType, ContentID, Filename, Filesize, FileID;

=cut

sub FormIDGetAllFilesData {
    my $Self = shift;

    return @{ $Self->{Backend}->FormIDGetAllFilesData(@_) };
}

=item FormIDGetAllFilesMeta()

returns an array with a hash ref of all files for a Form ID

Note: returns no content, only meta data.

    my @Data = $UploadCacheObject->FormIDGetAllFilesMeta(
        FormID => 12345,
    );

    Return data of hash is ContentType, ContentID, Filename, Filesize, FileID;

=cut

sub FormIDGetAllFilesMeta {
    my $Self = shift;

    return @{ $Self->{Backend}->FormIDGetAllFilesMeta(@_) };
}

=item FormIDCleanUp()

Removed no longer needed temporary files.

Each file older than 1 day will be removed.

    $UploadCacheObject->FormIDCleanUp();

=cut

sub FormIDCleanUp {
    my $Self = shift;

    return $Self->{Backend}->FormIDCleanUp(@_);
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<https://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (GPL). If you
did not receive this file, see L<https://www.gnu.org/licenses/gpl-3.0.txt>.

=cut
