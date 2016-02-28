package Sinoa::Web::Controller::Root {

  use Mojo::Base 'Mojolicious::Controller';
  
  # トップページ
  sub index {
    my $self = shift;
    
    my $form = $self->param('page') // 1;
    my ($bookmark,$page) = $self->model->bookmark->get_bookmark({page => $form,limit => 10});
    $self->stash(bookmark => $bookmark,page => $page,);
    
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
    
    $self->redirect_to($self->req->url->base); # ('/') だと特定の環境やcgi起動の時にバグる
  }

}

1;
