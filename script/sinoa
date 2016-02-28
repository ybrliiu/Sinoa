#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/../lib" }

#モード切り替え(development:開発、production:本番)
$ENV{MOJO_MODE} = 'development';

# Start command line interface for application
require Mojolicious::Commands;
Mojolicious::Commands->start_app('Sinoa::Web');
