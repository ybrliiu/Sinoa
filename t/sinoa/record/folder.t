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

my $obj;

subtest 'new' => sub {
  $obj = $class->new(['test']);
  isa_ok($obj,$class);
};

subtest 'edit' => sub {
  $obj->edit(['edit name']);
  is($obj->Name,'edit name');
  diag $obj->Name;
  $obj->edit([]);
  is($obj->Name,'edit name');
};

done_testing;
