use v5.14;
use warnings;
use utf8;

use Test::More;

$ENV{MOJO_MODE} = 'test';
$ENV{SINOA_DEPTH} = 2; # ディレクトリの深さ

my $class;

BEGIN {
  $class = 'Sinoa::Record::Bookmark';
  use_ok($class);
}

subtest 'new' => sub {
  my $obj = $class->new([qw{テストサイト http://test.t テストのサイトです テストタグ 2016/02/28}]);
  isa_ok($obj,$class);
  is ($class->filedir(),'/home/leiu/server/sinoa/t/sinoa/record/../../../etc/record/bookmark.dat');
};

done_testing;
