package Sinoa::Record {
  
  use Sinoa; # use v5.14,strict,warnings,utf8 & root_dir
  use Carp qw/carp croak/; # モジュールでのwarn/die;
  
  use Storable qw/fd_retrieve nstore_fd nstore/; # データ保存用
  
  sub new {
    my ($class,$filedir) = @_;
    my $self = {
      File => Sinoa::root_dir() . $filedir,
      FH => undef,
      Data => {}, # hashref
    };
    return bless $self,$class;
  }
  
  sub open {
    my $self = shift;
    my $lock = shift // '';
    if($lock){
      open($self->{FH},'+<',$self->{File}) or croak 'fileopen失敗:'.$self->{File};
      while(!flock($self->{FH},6)){ sleep(1); }
      $self->{Data} = fd_retrieve($self->{FH});
    }else{
      open($self->{FH},'<',$self->{File}) or $self->make();
      $self->{Data} = fd_retrieve($self->{FH});
      close $self->{FH};
    }
    return $self; # メソッドチェーン用 ここでメソッドチェーンできないと2行で書かないといけないから
  }
  
  sub make {
    my $self = shift;
    my %hash = ();
    nstore(\%hash,$self->{File});
  }
  
  sub close {
    my $self = shift;
    truncate($self->{FH},0) or croak 'truncate失敗 おそらく書き込みモードでファイルを開いていないか、書き込みモードで2度ファイルを開いている';
    seek($self->{FH},0,0) or croak 'seek失敗';
    nstore_fd($self->{Data},$self->{FH}) or croak 'nstore_fd失敗';
    close $self->{FH} or croak 'close失敗';
  }
  
  sub get_alldata {
    my $self = shift;
    return $self->{Data};
  }
  
  sub set_alldata {
    my ($self,$data) = @_;
    croak "It's not a hashref" unless ref $data eq 'HASH';
    $self->{Data} = $data;
  }
  
}

1;
