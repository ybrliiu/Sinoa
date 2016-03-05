package Sinoa::Web::Controller::Root {

  use Mojo::Base 'Mojolicious::Controller';
  
  # トップページ
  sub top {
    my $self = shift;
    
    # 表示するブックマークデータ取得
    my $mode = $self->param('mode') // '';
    my $keyword = $self->param('keyword') // '';
    my $folder = $self->param('folder') // '';
    my @dirs = split(/\//,$folder);
    my ($bookmark,$page) = $self->model->bookmark->get_bookmark({
      no => $self->param('page') // 1,
      switch => 10,
      mode => $mode,
      keyword => $keyword,
      folder => \@dirs,
    });
    
    # stash
    my $tmp = '';
    my @dirlinks = map { $tmp .= "$_/"; $tmp; } @dirs;
    $self->stash(
      bookmark => $bookmark,
      page => $page,
      mode => $mode,
      keyword => $keyword,
      folder => $folder,
      dirs => \@dirs,
      dirlinks => \@dirlinks,
    );
    
    # Render template "root/top.html.ep" with message
    $self->render();
  }

}

1;
