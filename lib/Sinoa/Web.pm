package Sinoa::Web {
  
  use Mojo::Base 'Mojolicious'; # 継承
  
  use Sinoa 'none';
  use Sinoa::Model;

  # サーバー起動時に一度だけ呼び出す
  sub startup {
    my $self = shift;
        
    # 設定ファイル読み込み
    $self->plugin('Config',{file => Sinoa->root_dir.'/etc/config/site.conf'});
    
    # フォーム検証の拡張(正規表現にマッチしない)
    $self->validator->add_check(not_like => sub { $_[2] =~ $_[3] });
    
    # helper
    my $model = Sinoa::Model->new();
    $self->helper(model => sub { $model });
    
    # Router
    my $r = $self->routes;
    $r->namespaces([qw/Sinoa::Web::Controller/]);
    $r->get('/')->to('root#top');
    $r->any('/top')->to('root#top');
    $r->get('/regist')->to('root#regist');
    $r->get('/registfolder')->to('root#registfolder');
    $r->post('/create')->to('root#create');
    $r->post('/createfolder')->to('root#createfolder');
    $r->post('/remove')->to('root#remove');
  }

}

1;
