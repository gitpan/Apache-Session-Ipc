#############################################################################
#
# Apache::Session::Store::Ipc
# Implements session object storage via IPC shared memeory
# Copyright(c) 2005 Xavier Guimard (x.guimard@free.fr>
# Distribute under the Artistic License
#
############################################################################

package Apache::Session::Store::Ipc;

use strict;

use IPC::Shareable;

use vars qw($VERSION);

our $VERSION = '0.01';

sub new {
    my $class = shift;

    return bless { shm => {} }, $class;
}

sub insert {
    my $self    = shift;
    my $session = shift;

    $self->_connect($session,1) unless ( tied( $self->{shm} ) );
    $self->{shm}->{ $session->{data}->{_session_id} } = $session->{serialized};
}

sub update {
    my $self    = shift;
    my $session = shift;

    $self->_connect($session) unless ( $self->{shm} );
    $self->{shm}->{ $session->{data}->{_session_id} } = $session->{serialized};
}

sub materialize {
    my $self    = shift;
    my $session = shift;

    $self->_connect($session) unless ( tied $self->{shm} );
    my $id = $session->{data}->{_session_id};
    die "Object does not exist in the data store" unless $self->{shm}->{$id};
    $session->{serialized} = $self->{shm}->{$id};
}

sub remove {
    my $self    = shift;
    my $session = shift;

    tied( $self->{shm} ) && ( tied $self->{shm} )->remove;
    delete $self->{shm};
}

sub close {
    my $self    = shift;
    my $session = shift;
    untie $self->{shm};
}

sub DESTROY {
    close(@_);
}

sub _connect {
    my($self,$session,$isNew) = @_;
    my $glue    = $session->{args}->{IpcName} || 'SESS';
    my $options = $session->{args}->{IpcOptions};
    $options->{create} = $isNew || 0;
    tie $self->{shm}, 'IPC::Shareable', $glue, $options
      or die "Unable to find glue: $glue";
}

1;

=pod

=head1 NAME

Apache::Session::Store::Ipc - Store persistent data on the IPC shared memory
segment.

=head1 SYNOPSIS


 use Apache::Session::Store::Ipc;
 
 my $store = new Apache::Session::Store::Ipc;
 
 $store->insert($ref);
 $store->update($ref);
 $store->materialize($ref);
 $store->remove($ref);

=head1 DESCRIPTION

This module fulfills the storage interface of Apache::Session.  The serialized
objects are stored in IPC shared memory segments.

=head1 OPTIONS

This module requires one argument in the usual Apache::Session style.  The
name of the option is IpcName, and the value is the "glue" (id) used to access
to the shared memory segment.
Example:

 tie %s, 'Apache::Session::Ipc', undef,
    {IpcName => 'SESS'};

You can also add other IPC::Shareable options using the "IpcOptions" option.
Example:

 tie %s, 'Apache::Session::Ipc', undef,
    {IpcName    => 'SESS',
     IpcOptions => {mode => 0600}
     };

See IPC::Shareable for more details.

=head1 AUTHOR

This module was written by Xavier Guimard <x.guimard@free.fr>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 by Xavier Guimard

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.

=head1 SEE ALSO

L<Apache::Session>, L<IPC::Shareable>
