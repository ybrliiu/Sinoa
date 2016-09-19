use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

$ENV{MOJO_MODE} = 'test';

my $t = Test::Mojo->new('Sinoa::Web');
$t->get_ok('/')->status_is(200)->content_like(qr/sinoa/i);
$t->get_ok('/top')->status_is(200)->content_like(qr/sinoa/i);
$t->get_ok('/add/bookmark')->status_is(200)->content_like(qr/sinoa/i);
$t->get_ok('/add/folder')->status_is(200)->content_like(qr/sinoa/i);

done_testing();
