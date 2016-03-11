use v5.14;
use warnings;
use utf8;

use Test::More;

$ENV{MOJO_MODE} = 'test';
$ENV{SINOA_DEPTH} = 1; # ディレクトリの深さ

my $class;

BEGIN {
  $class = 'Sinoa::Record';
  use_ok($class);
}

subtest 'new' => sub {
  my $obj = $class->new();
  isa_ok($obj,$class);
  can_ok($obj,qw/open make close get_alldata set_alldata/);
};

done_testing;
