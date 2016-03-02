package Sinoa::Model::Bookmark {
  
  use v5.14;
  use warnings;
  use utf8;
  use Carp qw/carp croak/;
  
  use Sinoa::Record;
  use Sinoa::Record::Bookmark;
  use Sinoa::Record::Folder;
  use Time::Piece; # 時刻
  
  sub new {
    my $class = shift;
    my $self = {
      Record => Sinoa::Record->new( Sinoa::Record::Bookmark->filedir() ),
    };
    return bless $self,$class;
  }
  
  sub _select_dir {
    my ($last_dir,$dirs) = @_;
    for(0..scalar(@$dirs)-1){
      $last_dir = $last_dir->{$dirs->[$_]}->Include;
    }
    return $last_dir;
  }
  
  sub _create {
    my ($self,$data,$dirs,$mode) = @_;
    my $pkg = "Sinoa::Record::$mode";
    my $obj = $pkg->new($data);
    my $rec = $self->{Record}->open(1);
    my $last_dir = _select_dir($rec->get_alldata(),$dirs);
    $last_dir->{$obj->Name} = $obj;
    $rec->close();
  }
  
  sub create {
    my ($self,$data) = @_;
    my $dirs = $_[2] // [];
    # こういうところにバリデーション書いてもいいかもね
    $data->[4] = _now();
    $data->[5] = time();
    $self->_create($data,$dirs,'Bookmark');
  }
    
  sub _now {
    my $t = localtime();
    return $t->year.'/'.$t->mon.'/'.$t->mday.' '.$t->hour.':'.$t->min.':'.$t->sec;
  }
  
  sub create_folder {
    my ($self,$name) = @_;
    my $dirs = $_[2] // [];
    $self->_create([$name],$dirs,'Folder');
  }
  
  sub remove {
    my ($self,$deletes) = @_;
    my $dirs = $_[2] // [];
    my $rec = $self->{Record}->open(1);
    my $last_dir = _select_dir($rec->get_alldata(),$dirs);
    delete $last_dir->{$_} for(@$deletes);
    $rec->close();
  }
  
  sub get_folderlist {
    my $self = shift;
    my @folderlist = _folderlist($self->{Record}->open->get_alldata(),'');
    unshift(@folderlist,'');
    return \@folderlist;
  }
  
  sub _folderlist {
    my ($bookmark,$char) = @_;
    map {
      unless( ___is_class($bookmark->{$_}) ){
        my $name = $bookmark->{$_}->Name;
        $char.$name, _folderlist($bookmark->{$_}->Include,"$char$name/");
      }else{
        ();
      }
    } sort(keys %$bookmark);
  }
  
  sub get_bookmark {
    my ($self,$option) = @_;
    my $bookmark = $self->{Record}->open;
    my %page = (
      switch => $option->{switch} // 10, # 何件で切り替えるか
      current => $option->{no} - 1 // 0, # 表示するページ数
      limit => int(@{$bookmark->get_list()} / $option->{switch} + 0.99), # ページ数、数が大きくなりすぎた時にバグる
    );
    my @tmp = @{_sort($bookmark->get_alldata(),$option)};
    my @bookmark = map {
      $tmp[$_] ? $tmp[$_] : ()
    } $page{current} * $page{switch}..$page{current} * $page{switch} + $page{switch} - 1;
    return \@bookmark,\%page;
  }
  
  sub _sort {
    my ($bookmark,$option) = @_;
    my @result;
    if($option->{mode} eq 'tag'){
      @result = __tag($bookmark,$option);
    }elsif($option->{mode} eq 'time'){
      @result = __time($bookmark,$option);
    }elsif($option->{mode} eq 'find'){
      @result = __like($bookmark,$option,'Name');
    }elsif($option->{mode} eq 'url'){
      @result = __like($bookmark,$option,'URL');
    }else{
      unless($option->{folder}){
        @result = __nomal($bookmark);
      }else{
        my $last_dir = _select_dir($bookmark,$option->{folder});
        @result = __nomal($last_dir);
      }
    }
    return \@result;
  }
  
  # object判定
  sub ___is_class { ref $_[0] eq 'Sinoa::Record::Bookmark' ? return 1 : return 0; }
  
  sub __tag{
    my ($bookmark,$option) = @_;
    map {
      if(___is_class $bookmark->{$_}){
        # bookmark obj
        $option->{'keyword'} eq $bookmark->{$_}->Tag ? $bookmark->{$_} : ();
      }else{
        # folder obj
        __tag($bookmark->{$_}->Include,$option);
      }
    } sort(keys %$bookmark);
  }
  
  sub __time{
    my ($bookmark,$option) = @_;
    map {
      ___is_class($bookmark->{$_}) ? $bookmark->{$_} : __time($bookmark->{$_}->Include,$option);
    } sort { $bookmark->{$a}->Time <=> $bookmark->{$b}->Time }(keys %$bookmark);
  }
  
  # URL,名前からの検索モード
  sub __like {
    my ($bookmark,$option,$mode) = @_;
    map {
      if(___is_class $bookmark->{$_}){
        $bookmark->{$_}->$mode =~ /$option->{'keyword'}/ ? $bookmark->{$_} : ();
      }else{
        __like($bookmark->{$_}->Include,$option,$mode);
      }
    } sort(keys %$bookmark);
  }
  
  sub __nomal {
    my $bookmark = shift;
    map { $bookmark->{$_} } sort(keys %$bookmark);
  }
  
}

1;

__END__

=encoding utf8

=head1 名前

Sinoa::Model::Bookmark - ブックマークデータを取得、操作するためのモジュール

=head1 概要
  
  ブックマークデータを取得、操作するためのモジュールです。
  コントローラ層(Sinoa::Web::Controller以下)で使用されます。
  
=head1 属性(フィールド)
  
=head2 Record
  
  データ処理の基本的な処理をするSinoa::Recordモジュールのオブジェクトを格納しています。
  この属性を使ってブックマークデータの処理を行います。
  外部からのアクセスを想定していないのでアクセッサはありませんし、
  外部から無理やりこの属性の値を利用したり変更したりすべきではありません。
  
=head1 メソッド
  
=head2 new
  
  普通のコンストラクタです。
  使用例:
  use Sinoa::Model::Bookmark;
  my $bookmark = Sinoa::Model::Bookmark->new();
  コントローラ層で(ヘルパー利用):
  my $bookmark = $self->model->bookmark->new();
  
=head2 _select_dir
  
  外部アクセスダメ
  引数$dirsに格納された順にFolderオブジェクトを辿っていき目的のフォルダのブックマーク一覧を取得する。
  create,create_folder,removeなどで使用
  
=head2 create
  
  引数からブックマークオブジェクトを作成し、データに書き込みます。
  
=head2 create_folder
  
  引数からブックマークフォルダオブジェクトを作成し、データに書き込みます。
  
=head2 remove
  
  引数:$self,$deletes(array_ref),$dirs(array_ref)
  $dirsで指定したフォルダの中のブックマーク、フォルダの内、$deletesで指定したキーのブックマークを全て削除します。
  使用例:
  $bookmark->remove([qw/bookmark1 bookmark2 bookmark3/],[qw/folder1 folder2/]);
  → folder1フォルダの中にあるfolder2フォルダの中にある、bookmark1,bookmark2,bookmark3
  という名前のブックマークもしくはフォルダーを削除する。
  
=head2 get_bookmark
  
  ブックマークのリストを取得します。
  引数:$self,$option(hashref)
  $option = {
    no => 1, # ページNo
    switch => 10, # 何件でページを切り替えるか
    mode => '', # 取得モード 空だと通常モード
    keyword => '', # 名前検索、URL検索、タグ検索の時に使うキーワード
    folder => ['folder','folder_child'..], # フォルダーの指定 取得モードが通常の時のみ有効
    # rootの方から小フォルダに向かって順番にarrayrefに書いていく
    # 例) testフォルダの中の、test2フォルダのブックマーク一覧を取り出したい場合
    # folder => ['test','test2'],
  };
  返却値;$bookmark(表示するブックマークを格納したarrayref),\%page(ページに関する情報)
  
=cut
