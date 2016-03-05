# ブックマーク、フォルダ追加系

package Sinoa::Web::Controller::Add {
  
  use Mojo::Base 'Mojolicious::Controller';
  
  sub _show_add {
    my $self = shift;
    $self->stash(folderlist => $self->model->bookmark->get_folderlist());
  }
  
  # ブックマーク登録画面
  sub bookmark {
    my $self = shift;
    $self->_show_add();
    $self->render();
  }
  
  # フォルダ登録画面
  sub folder {
    my $self = shift;
    $self->_show_add();
    $self->render();
  }
  
  # ブックマーク作成
  sub addbookmark {
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
  
  # ブックマークフォルダ作成
  sub addfolder {
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
  
}

1;
