package Sinoa {
  
  use strict;
  use warnings;
  use utf8;
  use feature ':5.14';
  
  use Mojo::Home;
  use Cwd 'abs_path';
  
  # インポート
  sub import {
    my $class = shift;
    my $flag = shift // '';
    
    unless($flag eq 'none'){
      # このモジュールをインポートしたモジュールに,use strict,warnings,utf8,v5.14 する
      $_->import for qw/strict warnings utf8/;
      feature->import($_) for qw/:5.14/;
    }
  }
  
  # プロジェクトルートディレクトリ取得
  sub root_dir {
    my $class = shift;
    state $project_dir;
    return $project_dir if $project_dir;
    my $home = Mojo::Home->new;
    $home->detect(ref $class);
    my $depth = '../';
    if($ENV{MOJO_MODE} eq 'test' && $ENV{SINOA_DEPTH} > 0){
      $depth .= '../' for 1..$ENV{SINOA_DEPTH};
    }
    $project_dir = $home->rel_dir($depth);
    return $project_dir;
  }

}

1;

__END__

=encoding utf8

=head1 名前
  
  Sinoa - webアプリSinoaのための基礎モジュール
  
=head1 概要
  
  webアプリSinoaのための基礎モジュールです。
  Sinoaの制作に役立つ機能が実装されています。
  
=head1 関数
  
=head2 import
  
  import は use Sinoa; でこのモジュールを読み込んだ時に実行されます。
  この関数が実行されることにより、use Sinoa をしたモジュール内で、use strict,use warnings,use utf8,use feature 5.14
  が実行されます。
  use Sinoa 'none'; で呼び出すと、何もインポートされません。
  
=head2 root_dir
  
  Sinoaのプロジェクトルートディレクトリを取得するための関数です。
  設定ファイルのロードなどで利用します。
  
=cut
