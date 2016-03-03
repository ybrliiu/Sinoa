package Sinoa::Record::Folder {
  
  use Sinoa; # use v5.14,strict,warnings,utf8 & root_dir
  use Carp qw/carp croak/; # モジュールでのwarn/die;
  
  my @field = qw/Name Include/; # 属性
  use Class::Accessor::Lite(new => 0); # アクセッサ作成
  Class::Accessor::Lite->mk_accessors(@field);
  
  sub new {
    my ($class,$data) = @_;
    my %self = map { $field[$_] => $data->[$_] // {} } 0..$#field;
    return bless \%self,$class;
  }
  
}

1;
