package Sinoa::Web::Controller::Edit {

  use Mojo::Base 'Mojolicious::Controller';
  
  sub bookmark {
    my $self = shift;
    
    my @dirs = split(/\//,$self->param('dir'));
    $self->stash(
      key => $self->param('key'),
      dir => $self->param('dir'),
      folderlist => $self->model->bookmark->get_folderlist(),
      obj => $self->model->bookmark->get_info($self->param('key'), \@dirs),
    );
    $self->render();
  }
  
  sub folder {
    my $self = shift;
    
    my @dirs = split(/\//,$self->param('dir'));
    $self->stash(
      key => $self->param('key'),
      dir => $self->param('dir'),
      folderlist => $self->model->bookmark->get_folderlist(),
      obj => $self->model->bookmark->get_info($self->param('key'), \@dirs),
    );
    $self->render();
  }
  
  # 編集
  sub edit {
    my $self = shift;
    
    my $validation = $self->validation;
    $validation->csrf_protect('csrf_token');
    $validation->required('Name')->size(1,30);
    $validation->required('URL')->size(1,255);
    $validation->optional('Description')->size(0,500);
    $validation->optional('Tag')->size(0,30);
    my @current = split(/\//,$self->param('current_folder'));
    my @next = split(/\//,$self->param('Folder'));
    
    $self->model->bookmark->edit(
      $self->param('name'),
      [
        $self->param('Name'),
        $self->param('URL'),
        $self->param('Description'),
        $self->param('Tag'),
      ],
      {
        current => \@current,
        current_str => $self->param('current_folder'),
        next => \@next,
        next_str => $self->param('Folder'),
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
