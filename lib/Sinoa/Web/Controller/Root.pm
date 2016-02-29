package Sinoa::Web::Controller::Root {

  use Mojo::Base 'Mojolicious::Controller';
  
  # トップページ
  sub top {
    my $self = shift;
    
    my $name = $self->param('name') // '';
    my $keyword = $self->param('keyword') // '';
    my ($bookmark,$page) = $self->model->bookmark->get_bookmark({
      no => $self->param('page') // 1,
      switch => 10,
      name => $name,
      keyword => $keyword,
    });
    
    $self->stash(
      bookmark => $bookmark,
      page => $page,
      name => $name,
      keyword => $keyword,
    );
    
    # Render template "root/index.html.ep" with message
    $self->render();
  }
  
  # ブックマーク登録
  sub regist {
    my $self = shift;
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
    
    if($validation->has_error){
      $self->render('root/regist');
      return 1;
    }
    
    $self->model->bookmark->create([
      $self->param('Name'),
      $self->param('URL'),
      $self->param('Description'),
      $self->param('Tag'),
    ]);
    
    $self->redirect_to('/top');
  }
  
  # ブックマーク削除
  sub remove {
    my $self = shift;
    $self->model->bookmark->remove($self->every_param('key'));
    $self->redirect_to('/top');
  }

}

1;
