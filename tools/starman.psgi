#!/usr/bin/plackup

BEGIN {
 if ( $ENV{'LSMB_WORKINGDIR'} && -f "$ENV{'LSMB_WORKINGDIR'}/lib/LedgerSMB.pm" ) { chdir $ENV{'LSMB_WORKINGDIR'}; }
}

package LedgerSMB::FCGI;

use lib 'lib';
use CGI::Emulate::PSGI;
use LedgerSMB::PSGI;
use LedgerSMB::Sysconfig;
use Plack::Builder;
use Plack::App::File;

# Optimization
use Plack::Middleware::ConditionalGET;
use Plack::Builder::Conditionals;

die 'Cannot verify version of libraries, may be including out of date modules?' unless $LedgerSMB::PSGI::VERSION == '1.5';


my $old_app = LedgerSMB::PSGI::old_app();
my $new_app = LedgerSMB::PSGI::new_app();

builder {
    enable match_if path(qr!.+\.(css|js|png|ico|jp(e)?g|gif)$!),
        'ConditionalGET';

    mount '/rest/' => LedgerSMB::PSGI::rest_app();

    # not using @LedgerSMB::Sysconfig::scripts: it has not only entry-points
    mount "/$_" => $old_app
        for ('aa.pl', 'am.pl', 'ap.pl',
             'ar.pl', 'gl.pl', 'ic.pl', 'ir.pl',
             'is.pl', 'oe.pl', 'pe.pl');

    mount "/$_" => $new_app
        for  (@LedgerSMB::Sysconfig::newscripts);

    mount '/stop.pl' => sub { exit; }
        if $ENV{COVERAGE};

    mount '/' => Plack::App::File->new( root => 'UI' )->to_app;
};

# -*- perl-mode -*-
