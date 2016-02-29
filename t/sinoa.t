use v5.14;
use warnings;
use utf8;

use Test::More;

$ENV{MOJO_MODE} = 'test';
$ENV{SINOA_DEPTH} = 0; # ディレクトリの深さ /t = 0,/t/sinoa = 1,/t/sinoa/model = 2

BEGIN {
  use_ok('Sinoa');
}

subtest 'root_dir' => sub {
  is (Sinoa::root_dir(),'/home/leiu/server/sinoa/t/..','root_dir');
};

done_testing;
