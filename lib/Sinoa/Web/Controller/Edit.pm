package Sinoa::Web::Controller::Edit {

  use Mojo::Base 'Mojolicious::Controller';
  
  sub _show_edit {
    my $self = shift;
  
    my @dirs = split(/\//,$self->param('dir'));
    $self->stash(
      key => $self->param('key'),
      dir => $self->param('dir'),
      folderlist => $self->model->bookmark->get_folderlist(),
      obj => $self->model->bookmark->get_info($self->param('key'), \@dirs),
    );
  }
  
  sub bookmark {
    my $self = shift;
    $self->_show_edit();
    $self->render();
  }
  
  sub folder {
    my $self = shift;
    $self->_show_edit();
    $self->render();
  }
  
  # ブクマ編集
  sub editbookmark {
    my $self = shift;
    
    my $validation = $self->validation;
    $validation->csrf_protect('csrf_token');
    $validation->required('current_Name')->size(1,30);
    $validation->required('next_Name')->size(1,30);
    $validation->required('next_URL')->size(1,255);
    $validation->optional('next_Description')->size(0,500);
    $validation->optional('next_Tag')->size(0,30);
    my @current = split(/\//,$self->param('current_folder'));
    my @next = split(/\//,$self->param('next_folder'));
    
    if($validation->has_error){
      $self->render('edit/bookmark');
      return 1;
    }
    
    $self->model->bookmark->edit(
      $self->param('current_Name'),
      [
        $self->param('next_Name'),
        $self->param('next_URL'),
        $self->param('next_Description'),
        $self->param('next_Tag'),
      ],
      {
        current => \@current,
        current_str => $self->param('current_folder'),
        next => \@next,
        next_str => $self->param('next_folder'),
      },
    );
    
    $self->redirect_to('/top');
  }
  
  # フォルダ編集
  sub editfolder {
    my $self = shift;
    
    my $validation = $self->validation;
    $validation->csrf_protect('csrf_token');
    $validation->required('current_Name')->size(1,30);
    $validation->required('next_Name')->size(1,30);
    my @current = split(/\//,$self->param('current_folder'));
    my @next = split(/\//,$self->param('next_folder'));
    
    if($validation->has_error){
      $self->render('edit/folder');
      return 1;
    }
    
    $self->model->bookmark->edit(
      $self->param('current_Name'),
      [$self->param('next_Name')],
      {
        current => \@current,
        current_str => $self->param('current_folder'),
        next => \@next,
        next_str => $self->param('next_folder'),
      },
    );
    
    $self->redirect_to('/top');
  }
  
  # ブックマークorフォルダ削除
  sub remove {
    my $self = shift;
    
    my $json = $self->req->json;
    
    my @dirs = split(/\//,$json->{dir});
    $self->model->bookmark->remove($json->{key},\@dirs);
    $self->render(text => 'response');
  }
  
}

1;
