######## ####################################################################
#
# Apache::Session::Lock::Ipc
# Ipc shared memory locking for Apache::Session
# Copyright(c) 2005 Xavier Guimard <x.guimard@free.fr>
# Distribute under the Artistic License
#
############################################################################

package Apache::Session::Lock::Ipc;

use strict;
use IPC::Shareable qw(:lock);
use Time::HiRes;

our $VERSION = '0.01';

sub new {
    my $class = shift;
    return bless { lock => 0, id => 0 }, $class;
}

sub acquire_read_lock {
    my $self    = shift;
    my $session = shift;

    return if $self->{lock};

    if ( !defined $self->{shm} ) {
        $self->{shm} = {};
        my $glue = $session->{args}->{IpcName} || 'SESS';
        my $options = $session->{args}->{IpcOptions};
        $options->{create} = 1 unless defined($options->{create});
        tie $self->{shm}, 'IPC::Shareable', $glue, $options;
    }
    for ( my $i = 0 ; $i < 3 ; $i++ ) {
        if ( ( tied $self->{shm} )->shlock(LOCK_SH|LOCK_NB) ) {
            return $self->{lock} = 1;
        }
        usleep(10000);
    }
    return $self->{lock} = 0;
}

sub acquire_write_lock {
    $_[0]->acquire_read_lock( $_[1] );
}

sub release_read_lock {
    my $self = shift;

    if ( $self->{lock} ) {
        ( tied $self->{shm} )->shunlock;
    }

    $self->{lock} = 0;
}

sub release_write_lock {
    $_[0]->release_read_lock( $_[1] );
}

sub release_all_locks {
    $_[0]->release_read_lock( $_[1] );
}

sub DESTROY {
    my $self = shift;

    untie $self->{shm};
    $self->release_all_locks;
}

1;

=pod

=head1 NAME

Apache::Session::Lock::Ipc - Provides mutual exclusion using IPC

=head1 SYNOPSIS

 use Apache::Session::Lock::Ipc;
 
 my $locker = new Apache::Session::Lock::Ipc;
 
 $locker->acquire_read_lock($ref);
 $locker->acquire_write_lock($ref);
 $locker->release_read_lock($ref);
 $locker->release_write_lock($ref);
 $locker->release_all_locks($ref);

=head1 DESCRIPTION

Apache::Session::Lock::Ipc fulfills the locking interface of 
Apache::Session. Mutual exclusion is achieved through the use of shlock and
shunlock functions of IPC::Shareable. Since this module does not support the
notions of read and write locks, this module only supports exclusive locks.
When you request a shared read lock, it is instead promoted to an exclusive
write lock.

=head1 CONFIGURATION

This module must know the name of the "glue" (the id of the shared segment).
By default, "SESS" is used.

Be carefull to the name used because it has to be composed by four characters.
Example:

 tie %hash, 'Apache::Session::Ipc', $id, {
     IpcName => 'SESS',
 };

You can also add other IPC::Shareable options using the "IpcOptions" option.
Example:

 tie %s, 'Apache::Session::Ipc', undef,
    {IpcName    => 'SESS',
     IpcOptions => {mode => 0600}
     };

=head1 AUTHOR

This module was written by Xavier Guimard <x.guimard@free.fr>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 by Xavier Guimard

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.

=head1 SEE ALSO

L<Apache::Session>, L<IPC::Shareable>
