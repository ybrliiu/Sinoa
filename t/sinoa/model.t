use v5.14;
use warnings;
use utf8;

use Test::More;

$ENV{MOJO_MODE} = 'test';

my $class;

BEGIN {
  $class = 'Sinoa::Model';
  use_ok($class);
}

subtest 'new' => sub {
  my $obj = $class->new();
  isa_ok($obj,$class);
  can_ok($obj,qw/bookmark/);
};

done_testing;
