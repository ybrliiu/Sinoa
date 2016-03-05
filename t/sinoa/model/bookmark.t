use v5.14;
use warnings;
use utf8;

use Test::More;
use Data::Dumper;

$ENV{MOJO_MODE} = 'test';
$ENV{SINOA_DEPTH} = 2; # ディレクトリの深さ /t = 0,/t/sinoa = 1,/t/sinoa/model = 2

my $class;
my $obj;

BEGIN {
  $class = 'Sinoa::Model::Bookmark';
  use_ok($class);
}

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
  ],[]);
  ok $obj->create([
    'test2',
    'http://',
    'none',
    'test',
  ],[]);
};

subtest 'create_folder' => sub {
  ok $obj->create_folder('tfolder',[]);
  ok $obj->create_folder('in_folder_test',[]);
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
  my @folder_list = @{$obj->get_folderlist()};
  diag $_ for @folder_list;
  ok 1;
};

subtest 'remove' => sub {
  ok $obj->remove(['remove'],['tfolder']);
  ok $obj->remove([qw/test test2 tfolder/],[]);
};

subtest 'get_bookmark' => sub {
  my ($bookmark,$page) = $obj->get_bookmark({
    no => 1,
    switch => 10,
    mode => '',
    keyword => '',
    folder => [],
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
    folder => [],
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
};

subtest 'get_info' => sub {
  my $bookmark = $obj->get_info('in_folder',['in_folder_test']);
  is($bookmark->URL,'http://in_folder');
};

subtest 'edit' => sub {
  ok $obj->edit(
    'in_folder',
    [
      'edit_name',
      'http://edit',
      'this is edited bookmark.',
      'tag',
    ],
    {
      current => ['in_folder_test'],
      current_str => 'in_folder_test',
      next => [],
      next_str => '',
    },
  );
    ok $obj->edit(
    'edit_name',
    [
      'edit_name',
      'http://edit2',
      'this is edited bookmark---2',
      'tag-22',
    ],
    {
      current => [],
      current_str => '',
      next => [],
      next_str => '',
    },
  );
  ok $obj->remove(['edit_name'],[]);
  $obj->remove(['in_folder_test'],[]); # テストに使ったフォルダを削除
};

done_testing;
