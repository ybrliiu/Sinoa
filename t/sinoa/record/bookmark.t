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

my $obj;

subtest 'new' => sub {
  $obj = $class->new([qw{テストサイト http://test.t テストのサイトです テストタグ 2016/02/28 1111111}]);
  isa_ok($obj,$class);
  is ($class->filedir(),'/etc/record/bookmark.dat');
};

subtest 'edit' => sub {
  $obj->edit(['edit test','','うほおおお','開発','','']);
  is($obj->Name,'edit test');
  is($obj->URL,'http://test.t');
  is($obj->Description,'うほおおお');
  is($obj->Tag,'開発');
  is($obj->Date,'2016/02/28');
  is($obj->Time,'1111111');
};

done_testing;
