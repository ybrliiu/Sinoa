package Sinoa {
  
  use v5.14;
  use warnings;
  use utf8;
  
  use Mojo::Home;
  use Cwd 'abs_path';

  # プロジェクトルートディレクトリ取得
  sub root_dir {
    my $self = shift;
    state $project_dir;
    return $project_dir if $project_dir;
    my $home = Mojo::Home->new;
    $home->detect(ref $self);
    my $depth = '../';
    if($ENV{MOJO_MODE} eq 'test' && $ENV{SINOA_DEPTH} > 0){
      $depth .= '../' for 1..$ENV{SINOA_DEPTH};
    }
    $project_dir = $home->rel_dir($depth);
    return $project_dir;
  }

}

1;
