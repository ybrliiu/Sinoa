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
    $self->helper(model => sub { $model }); # model層呼び出し
    $self->helper(line_break => sub { # 改行用 for template
      $_[1] =~ s/\n/<br>/g;
      return Mojo::ByteStream->new($_[1]);
    });
    
    # Router
    my $r = $self->routes;
    $r->namespaces([qw/Sinoa::Web::Controller/]);
    
    $r->get('/')->to('root#top');
    $r->any('/top')->to('root#top');
    
    $r->get('/add/bookmark')->to('add#bookmark');
    $r->get('/add/folder')->to('add#folder');
    $r->post('/add/addbookmark')->to('add#addbookmark');
    $r->post('/add/addfolder')->to('add#addfolder');
    
    $r->get('/edit/bookmark')->to('edit#bookmark');
    $r->get('/edit/folder')->to('edit#folder');
    $r->post('/edit/editbookmark')->to('edit#editbookmark');
    $r->post('/edit/editfolder')->to('edit#editfolder');
    $r->any('/edit/remove')->to('edit#remove');
  }

}

1;
