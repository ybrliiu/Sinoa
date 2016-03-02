use v5.14;
use warnings;
use utf8;

use Test::More;

$ENV{MOJO_MODE} = 'test';
$ENV{SINOA_DEPTH} = 2; # ディレクトリの深さ

my $class;

BEGIN {
  $class = 'Sinoa::Record::Folder';
  use_ok($class);
}

subtest 'new' => sub {
  my $obj = $class->new(['test']);
  isa_ok($obj,$class);
};

done_testing;
