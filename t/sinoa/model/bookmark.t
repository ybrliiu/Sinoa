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

my $obj;

subtest 'new' => sub {
  $obj = $class->new();
  isa_ok($obj,$class);
  can_ok($obj,qw/create _now get_bookmark/);
};

subtest 'get_bookmark' => sub {
  my ($bookmark,$page) = $obj->get_bookmark({no => 1,switch => 10});
  is(ref $bookmark,'ARRAY');
  is(ref $page,'HASH');
};

subtest 'create' => sub {
  ok $obj->create([
    'test',
    'http://',
    'none',
    'test',
  ]);
  ok $obj->create([
    'test2',
    'http://',
    'none',
    'test',
  ]);
};

subtest 'remove' => sub {
  ok $obj->remove([qw/test test2/]);
};

done_testing;
