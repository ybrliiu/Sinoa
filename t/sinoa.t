use v5.14;
use warnings;
use utf8;

use Test::More;

$ENV{MOJO_MODE} = 'test';

BEGIN {
  use_ok('Sinoa');
}

subtest 'root_dir' => sub {
  like Sinoa::root_dir(), qr/Sinoa/;
};

done_testing;
