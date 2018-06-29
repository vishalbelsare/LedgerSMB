
package Dancer2::Plugin::SessionDatabase;

=head1 NAME

Dancer2::Plugin::SessionDatabase - Database handle from session parameters

=head1 DESCRIPTION

This Dancer2 plugin implements the C<database> keyword tailored to the
use of LedgerSMB's handling of database connections, where the web
application user maps uniquely to a database connection user, requiring
a database connection per user.

=cut

use strict;
use warnings;
use Carp qw/croak/;
use DBI;

use Dancer2::Core::Types qw(Int Str);
use Dancer2::Plugin;

=head1 ATTRIBUTES

=head2 host

Taken from the plugin configuration, the host name or IP address of the
database server.

=cut

has host => (
    is          => 'ro',
    isa         => Str,
    from_config => sub { 'localhost' },
);

=head2 port

Taken from the plugin configuration, the port on C<host> to connect
to the database server.

=cut

has port => (
    is          => 'ro',
    isa         => Int,
);

our $VERSION = '0.001';

=head1 METHODS

This module doesn't define any methods.

=head1 KEYWORDS

=head2 database($db_name)

Returns a database connection created using the session credentials,
configured host name and port against the database with C<$db_name>,
or the session default database when C<$db_name> isn't provided.

Note that the database handle may be cached between invocations and
a cached instance may be returned.

=cut

register database => sub {
    my $self = shift;
    my $db = shift;

    my $session = $self->app->session;
    my $dbname = $db // $session->read('__auth_extensible_database');
    my $username = $session->read('logged_in_user');
    my $password = $session->read('__auth_extensible_pass');
    my $dbh = DBI->connect('dbi:Pg:database=' . $dbname
                           . ';host=' . $self->host,
                           $username, $password)
        or croak DBI->errstr;

    return $dbh;
};

=head1 LICENSE AND COPYRIGHT

This module is copyright (C) 2018, the LedgerSMB Core Team and subject to
the GNU General Public License (GPL) version 2, or at your option, any later
version.  See the COPYRIGHT and LICENSE files for more information.

=cut


register_plugin;

1;
