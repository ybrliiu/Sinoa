package Sinoa::Record::Bookmark {
  
  use v5.14;
  use warnings;
  use utf8;
  use Carp qw/carp croak/; # モジュールでのwarn/die;
  
  my @field = qw/Name URL Description Tag Date Time/; # 属性
  use Class::Accessor::Lite(new => 0); # アクセッサ作成
  Class::Accessor::Lite->mk_accessors(@field);
  
  sub new {
    my ($class,$data) = @_;
    # @field と array_refの引数からオブジェクトにするハッシュを作る
    my %self = map { $field[$_] => $data->[$_] // croak "Undefined field when make field $field[$_]" } 0..$#field;
    return bless \%self,$class;
  }
  
  sub filedir {
    my $class = shift;
    return '/etc/record/bookmark.dat';
  }
  
}

1;