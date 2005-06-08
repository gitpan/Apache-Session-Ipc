#############################################################################
#
# Apache::Session::Ipc
# Apache persistent user sessions in a Ipc shared segment
# Copyright(c) 2005 Xavier Guimard (x.guimard@free.fr)
# Distribute under the Artistic License
#
############################################################################

package Apache::Session::Ipc;

use 5.006001;
use strict;
use warnings;

use Apache::Session;
use Apache::Session::Lock::Ipc;
use Apache::Session::Store::Ipc;
use Apache::Session::Generate::MD5;
use Apache::Session::Serialize::Storable;

our @ISA = qw(Apache::Session);
our $VERSION = 0.01;

sub populate {
    my $self = shift;

    $self->{object_store} = new Apache::Session::Store::Ipc $self;
    $self->{lock_manager} = new Apache::Session::Lock::Ipc $self;
    $self->{generate}     = \&Apache::Session::Generate::MD5::generate;
    $self->{validate}     = \&Apache::Session::Generate::MD5::validate;
    $self->{serialize}    = \&Apache::Session::Serialize::Storable::serialize;
    $self->{unserialize}  = \&Apache::Session::Serialize::Storable::unserialize;

    return $self;
}

1;

=pod

=head1 NAME

Apache::Session::Ipc - An implementation of Apache::Session

=head1 SYNOPSIS

  use Apache::Session::Ipc;
 
 tie %session, 'Apache::Session::Ipc, $id, {
    IpcName => 'SESS',

 };

=head1 DESCRIPTION

This module is an implementation of Apache::Session.  It uses the IPC shared
memory store. See the example, and the documentation for
Apache::Session::Store::Ipc and Apache::Session::Lock::Ipc for more
details.

=head1 AUTHOR

This module was written by Xavier Guimard <x.guimard@free.fr>
 
=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 by Xavier Guimard

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.

=head1 SEE ALSO

L<Apache::Session::File>, L<Apache::Session::Flex>,
L<Apache::Session::DB_File>, L<Apache::Session::Postgres>, L<Apache::Session>

=cut
