package Sinoa::Web::Controller::Root {

  use Mojo::Base 'Mojolicious::Controller';
  
  # トップページ
  sub top {
    my $self = shift;
    
    # 表示するブックマークデータ取得
    my $name = $self->param('name') // '';
    my $keyword = $self->param('keyword') // '';
    my $folder = $self->param('folder') // '';
    my @dirs = split(/\//,$folder);
    my ($bookmark,$page) = $self->model->bookmark->get_bookmark({
      no => $self->param('page') // 1,
      switch => 10,
      mode => $name,
      keyword => $keyword,
      folder => \@dirs,
    });
    
    # stash
    my $tmp = '';
    my @dirlinks = map { $tmp .= "$_/"; $tmp; } @dirs;
    $self->stash(
      bookmark => $bookmark,
      page => $page,
      name => $name,
      keyword => $keyword,
      folder => $folder,
      dirs => \@dirs,
      dirlinks => \@dirlinks,
    );
    
    # Render template "root/index.html.ep" with message
    $self->render();
  }
  
  # ブックマーク登録
  sub regist {
    my $self = shift;
    $self->stash(folderlist => $self->model->bookmark->get_folderlist());
    $self->render();
  }
  
  # ブックマーク登録(フォーム処理)
  sub create {
    my $self = shift;
    
    my $validation = $self->validation;
    $validation->csrf_protect('csrf_token');
    $validation->required('Name')->size(1,30);
    $validation->required('URL')->size(1,255);
    $validation->optional('Description')->size(0,500);
    $validation->optional('Tag')->size(0,30);
    my @dirs = split(/\//,$self->param('folder'));
    
    if($validation->has_error){
      $self->render('root/regist');
      return 1;
    }
    
    $self->model->bookmark->create([
      $self->param('Name'),
      $self->param('URL'),
      $self->param('Description'),
      $self->param('Tag'),
    ],\@dirs);
    
    $self->redirect_to('/top');
  }
  
  # ブックマークフォルダ登録
  sub registfolder {
    my $self = shift;
    $self->stash(folderlist => $self->model->bookmark->get_folderlist());
    $self->render();
  }
  
  # ブックマークフォルダ作成
  sub createfolder {
    my $self = shift;
    
    my $validation = $self->validation;
    $validation->csrf_protect('csrf_token');
    $validation->required('Name')->size(1,30)->not_like(qr/\//);
    my @dirs = split(/\//,$self->param('folder'));
    
    if($validation->has_error){
      $self->render('/registfolder');
      return 1;
    }
    
    $self->model->bookmark->create_folder($self->param('Name'),\@dirs);
    
    $self->redirect_to('/top');
  }
  
  # ブックマーク削除
  sub remove {
    my $self = shift;
    my @dirs = split(/\//,$self->param('folder'));
    $self->model->bookmark->remove($self->every_param('key'),\@dirs);
    $self->redirect_to('/top');
  }

}

1;
