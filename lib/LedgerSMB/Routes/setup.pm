
package LedgerSMB::Routes::setup;

=head1 NAME

LedgerSMB::Routes::setup - Route definitions for setup application

=head1 DESCRIPTION



=cut

use Dancer2 appname => 'LedgerSMB/Setup';

use Dancer2::Plugin::Auth::Extensible;
use Dancer2::Plugin::SessionDatabase;

use LedgerSMB;
use LedgerSMB::Database;
use LedgerSMB::Sysconfig;

set layout => 'setup';

=head1 METHODS

=head2 render_login_template

This method hooks into C<Dancer2::Auth::Extensible>'s C<login_page_handler>
in order to override the default behaviour of applying the layout
to the login page, because the login page is a stand-alone page.

=cut


sub render_login_template {
    template 'transparent_login' => {
        return_url => query_parameters()->get('return_url')
    }, { layout => undef };
}

=head1 HOOK IMPLEMENTATIONS

=head2 before

=cut

hook before => sub {
    # we want separate auth cookies for setup and the main app
    engine('session')->{cookie_name} = 'ledgersmb.setup';
};

=head2 before_template_render

=cut

hook before_template_render => sub {
    my ($tokens) = @_;

    $tokens->{text} = sub { return shift };
    $tokens->{ledgersmb_version} = $LedgerSMB::VERSION;
    $tokens->{username} = logged_in_user ? logged_in_user->{username} : '';
};


sub _list_databases {
    my $query = q{SELECT datname FROM pg_database
                   WHERE datallowconn
                         AND NOT datistemplate
                  ORDER BY datname};
    my $sth = database->prepare($query);
    my $databases = [];

    $sth->execute;
    while (my $row = $sth->fetchrow_hashref) {
        push @$databases, $row->{datname};
    }

    return $databases;
}

sub _list_users {
    return [] unless param('database');

    my $query = q{SELECT id, username FROM users
                  ORDER BY username};
    my $sth = database(param('database'))->prepare($query);
    my $users = [];

    $sth->execute;
    while (my $row = $sth->fetchrow_hashref) {
        push @$users, $row;
    }

    return $users;
}

sub _list_templates {
    my $templates = [];
    opendir ( DIR, $LedgerSMB::Sysconfig::templates)
        or die "Couldn't open template directory: $!";

    while( my $name = readdir(DIR)){
        next if ($name =~ /^\./);
        if (-d (LedgerSMB::Sysconfig::templates() . "/$name") ) {
            push @$templates, $name;
        }
    }
    closedir(DIR);
    return $templates;
}



=head1 ROUTES

=head2 / [GET]

=cut

get '/' => require_login sub {
    my $databases = _list_databases;
    my $users = _list_users;
    my $templates = _list_templates;

    template 'setup_welcome', {
        database => param('database'),
        databases => $databases,
        users => $users,
        templates => $templates,
    };
};

<<<<<<< HEAD
=======
sub _template_create_company {
    my $errormessage = shift;
    my $dbconfig = LedgerSMB::Database::Config->new;
    my $charts = $dbconfig->charts_of_accounts;

    for my $type (qw( chart gifi sic )) {
        for my $locale (keys %$charts) {
            $charts->{$locale}->{$type} =
                [ map { +{ code => $_ } } @{$charts->{$locale}->{$type}} ];
        }
    }
    template 'create-company', {
        'coa_countries' => [ sort { $a->{name} cmp $b->{name} }
                             values %$charts ],
        'coa_data' => $charts,
        'templates' => $dbconfig->templates,
        'username' => '',
        'errormessage' => $errormessage,
        'salutations' => [
            { id => 1, salutation => 'Dr.' },
            { id => 2, salutation => 'Miss.' },
            { id => 3, salutation => 'Mr.' },
            { id => 4, salutation => 'Mrs.' },
            { id => 5, salutation => 'Ms.' },
            { id => 6, salutation => 'Sir.' }
            ],
        'countries' => _list_countries(),
        'perm_sets' => [
            { id =>  0, label => 'Manage Users' },
            { id =>  1, label => 'Full Permissions' },
            { id => -1, label => 'No changes' },
            ],
    };
}

=head2 /create-company [POST]

=cut

>>>>>>> 56c3101a3... * Add Routes::setup docs
post '/create-company' => require_login sub {
    'Todo'
};

=head2 /create-user [POST]

=cut

post '/create-user' => require_login sub {
    'Todo'
};

=head2 /edit-user [POST]

=cut

get '/edit-user' => require_login sub {
    'Todo'
};

=head2 /upgrade [POST]

=cut

post '/upgrade' => sub {
    'Todo'
};

=head2 /load-templates [POST]

=cut

post '/load-templates' => sub {
    'Todo'
};

=head2 /setup [GET]

=cut

get '/setup/?' => require_login sub {
    # Workaround for
    # https://github.com/PerlDancer/Dancer2-Plugin-Auth-Extensible/issues/82
    redirect '/';
};


=head1 LICENSE AND COPYRIGHT

This module is copyright (C) 2018, the LedgerSMB Core Team and subject to
the GNU General Public License (GPL) version 2, or at your option, any later
version.  See the COPYRIGHT and LICENSE files for more information.

=cut


1;
