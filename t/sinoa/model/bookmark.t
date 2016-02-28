use v5.14;
use warnings;
use utf8;

use Test::More;

$ENV{MOJO_MODE} = 'test';
$ENV{SINOA_DEPTH} = 2; # ディレクトリの深さ /t = 0,/t/sinoa = 1,/t/sinoa/model = 2

my $class;

BEGIN {
  $class = 'Sinoa::Model::Bookmark';
  use_ok($class);
}

subtest 'new' => sub {
  my $obj = $class->new();
  isa_ok($obj,$class);
  can_ok($obj,qw/create _now get_bookmark/);
};

done_testing;
