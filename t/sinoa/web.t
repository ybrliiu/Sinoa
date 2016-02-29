use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

$ENV{MOJO_MODE} = 'test';
$ENV{SINOA_DEPTH} = 1; # ディレクトリの深さ

my $t = Test::Mojo->new('Sinoa::Web');
$t->get_ok('/')->status_is(200)->content_like(qr/sinoa/i);
$t->get_ok('/top')->status_is(200)->content_like(qr/sinoa/i);
$t->get_ok('/regist')->status_is(200)->content_like(qr/sinoa/i);

done_testing();
