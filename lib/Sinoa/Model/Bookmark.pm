package Sinoa::Model::Bookmark {
  
  use Sinoa; # use v5.14,warnings,utf8 & root_dir
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
  
  # 指定フォルダの中身を取り出すため
  sub _select_dir {
    my ($last_dir,$dirs) = @_;
    for(0..@$dirs-1){
      $last_dir = $last_dir->{$dirs->[$_]}->Include;
    }
    return $last_dir;
  }
  
  # object判定
  sub _is_class { ref $_[0] eq 'Sinoa::Record::Bookmark' ? return 1 : return 0; }
  
  sub _create {
    my ($self,$data,$dirs,$mode) = @_;
    my $pkg = "Sinoa::Record::$mode";
    my $obj = $pkg->new($data);
    my $rec = $self->{Record}->open(1);
    my $last_dir = _select_dir($rec->get_alldata(),$dirs);
    $last_dir->{$obj->Name} = $obj;
    $rec->close();
  }
  
  sub _now {
    my $t = localtime();
    return $t->year.'/'.$t->mon.'/'.$t->mday.' '.$t->hour.':'.$t->min.':'.$t->sec;
  }
  
  # ブックマーク作成
  sub create {
    my ($self,$data,$dirs) = @_;
    # こういうところにバリデーション書いてもいいかもね
    $data->[4] = _now();
    $data->[5] = time();
    $self->_create($data,$dirs,'Bookmark');
  }
  
  # フォルダ作成
  sub create_folder {
    my ($self,$name,$dirs) = @_;
    $self->_create([$name],$dirs,'Folder');
  }
  
  # ブックマークorフォルダの情報１つ取得
  sub get_info {
    my ($self,$name,$dirs) = @_;
    my $current = _select_dir( $self->{Record}->open->get_alldata(), $dirs );
    return $current->{$name};
  }
  
  # 名前変更するとき
  sub _name_change {
    my ($dir,$oldname,$newname) = @_;
    if($oldname ne $newname){
      $dir->{$newname} = $dir->{$oldname};
      delete $dir->{$oldname};
    }
  }
  
  # フォルダ、ブックマークデータ編集,場所変更
  sub edit {
    my ($self,$name,$data,$folders) = @_;
    
    # 内容の書き換え
    my $rec = $self->{Record}->open(1);
    my $bookmark = $rec->get_alldata();
    my $current = _select_dir($bookmark, $folders->{current});
    my $obj = $current->{$name};
    $obj->edit($data);
    
    # 場所を変更するとき
    if($folders->{'current_str'} ne $folders->{'next_str'}){
      my $next = _select_dir($bookmark, $folders->{'next'});
      $next->{$name} = $obj;
      delete $current->{$name};
      _name_change($next, $name, $obj->Name);
    }else{
      _name_change($current, $name, $obj->Name);
    }
    $rec->close();
  }
  
  # ブクマorフォルダ削除
  sub remove {
    my ($self,$deletes,$dirs) = @_;
    my $rec = $self->{Record}->open(1);
    my $last_dir = _select_dir($rec->get_alldata(),$dirs);
    delete $last_dir->{$_} for(@$deletes);
    $rec->close();
  }

  sub _folderlist {
    my ($bookmark,$char) = @_;
    map {
      unless( _is_class($bookmark->{$_}) ){
        my $name = $bookmark->{$_}->Name;
        "$char$name/", _folderlist($bookmark->{$_}->Include,"$char$name/");
      }else{
        ();
      }
    } sort(keys %$bookmark);
  }
  
  # フォルダリスト取得
  sub get_folderlist {
    my $self = shift;
    my @folderlist = _folderlist($self->{Record}->open->get_alldata(),'');
    unshift(@folderlist,'');
    return \@folderlist;
  }
  
  # ブックマークリスト取得
  sub get_bookmark {
    my ($self,$option) = @_;
    $option->{folder} //= [];
    
    my $rec = $self->{Record}->open;
    my %page = (
      switch => $option->{switch} // 10, # 何件で切り替えるか
      current => $option->{no} - 1 // 0, # 表示するページ数
      limit => undef, # ページ数,値を返す前に代入
    );
    
    # ブックマークを指定された順にソートする
    my @tmp = @{_sort($rec->get_alldata(),$option)};
    
    # 表示するブックマークを抽出
    my @bookmark = map {
      $tmp[$_] ? $tmp[$_] : ()
    } $page{current} * $page{switch}..$page{current} * $page{switch} + $page{switch} - 1;
    
    $page{limit} = int(@tmp / $option->{switch} + 0.99); # 数が大きすぎるとバグる  
    return \@bookmark,\%page;
  }
  
  # modeで指定されたとおりにソート
  sub _sort {
    my ($bookmark,$option) = @_;
    my @result = do {
      if ($option->{mode} eq 'tag') { __tag($bookmark, $option) }
      elsif ($option->{mode} eq 'time') { __time($bookmark, $option) }
      elsif ($option->{mode} eq 'find') { __like($bookmark, $option, 'Name') }
      elsif ($option->{mode} eq 'url') { __like($bookmark, $option, 'URL') }
      else { __nomal( _select_dir($bookmark, $option->{folder}) ) }
    };
    return \@result;
  }
  
  # タグ
  sub __tag{
    my ($bookmark,$option) = @_;
    map {
      if( _is_class($bookmark->{$_}) ){
        # bookmark obj
        $option->{'keyword'} eq $bookmark->{$_}->Tag ? $bookmark->{$_} : ();
      }else{
        # folder obj
        __tag($bookmark->{$_}->Include,$option);
      }
    } sort(keys %$bookmark);
  }
  
  # 時間順
  sub __time{
    my ($bookmark,$option) = @_;
    map {
      _is_class($bookmark->{$_}) ? $bookmark->{$_} : __time($bookmark->{$_}->Include,$option);
    } sort { $bookmark->{$a}->Time <=> $bookmark->{$b}->Time }(keys %$bookmark);
  }
  
  # URL,名前からの検索モード
  sub __like {
    my ($bookmark,$option,$mode) = @_;
    map {
      if( _is_class($bookmark->{$_}) ){
        $bookmark->{$_}->$mode =~ /$option->{'keyword'}/ ? $bookmark->{$_} : ();
      }else{
        __like($bookmark->{$_}->Include,$option,$mode);
      }
    } sort(keys %$bookmark);
  }
  
  # 通常、フォルダ階層表示
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
  
=head2 edit
  
  ブックマーク、フォルダの情報を編集します。
  引数:$self,$name,$data,$folders
  $name:編集するbookmark,folderの名前
  $data:bookmark,folderオブジェクトを編集の情報,array_ref
    bookmarkのとき:[
      Name,
      URL,
      Description, # 説明文
      Tag,
    ];
    folderのとき:[
      Name,
    ];
  $folders:フォルダ関係の情報,hash_ref
    $folders = {
      current => '現在編集中のbookmark,folderがあるフォルダ(階層ごとに分割して配列に格納したもの)',
      current_str => '現在編集中のbookmark,folderがあるフォルダ(パス)',
      next => '移動先の...',
      next_str => '移動先の...',
    };
  
=cut
