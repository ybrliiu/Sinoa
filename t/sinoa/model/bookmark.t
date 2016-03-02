use v5.14;
use warnings;
use utf8;

use Test::More;
use Data::Dumper;

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

subtest 'create_folder' => sub {
  ok $obj->create_folder('tfolder');
  ok $obj->create_folder('in_folder_test');
};

subtest 'create_in_folder' => sub {
  ok $obj->create([
    'in_folder',
    'http://in_folder',
    'test-in_folder',
    '',
  ],['in_folder_test']);
  ok $obj->create([
    'remove',
    'http://remo.ve',
    'test',
    '',
  ],['tfolder']);
};

subtest 'create_folder_in_folder' => sub {
  ok $obj->create_folder('in_in',['in_folder_test']);
};

subtest 'folder_list' => sub {
  for(@{$obj->get_folderlist()}){
    diag $_;
  }
  ok 1;
};

subtest 'remove' => sub {
  ok $obj->remove(['remove'],['tfolder']);
  ok $obj->remove([qw/test test2 tfolder/]);
};

subtest 'get_bookmark' => sub {
  my ($bookmark,$page) = $obj->get_bookmark({
    no => 1,
    switch => 10,
    mode => '',
    keyword => '',
    folder => '',
  });
  is(ref $bookmark,'ARRAY');
  is(ref $page,'HASH');
  # diag(Dumper $bookmark); diag は テストでのsayみたいな感じ
  # diag($bookmark->[0]);
};

subtest 'get_bookmark_find' => sub {
  my ($bookmark,$page) = $obj->get_bookmark({
    no => 1,
    switch => 10,
    mode => 'find',
    keyword => 'in',
    folder => '',
  });
  is(ref $bookmark,'ARRAY');
  # ちゃんとin_folderがみつかるか
};

subtest 'get_bookmark_infolder' => sub {
  my ($bookmark,$page) = $obj->get_bookmark({
    no => 1,
    switch => 10,
    mode => '',
    keyword => '',
    folder => ['in_folder_test'],
  });
  is(ref $bookmark,'ARRAY');
  
  $obj->remove(['in_folder_test']); # テストに使ったフォルダを削除
};

done_testing;
