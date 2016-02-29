package Sinoa::Model::Bookmark {
  
  use v5.14;
  use warnings;
  use utf8;
  use Carp qw/carp croak/;
  
  use Time::Piece; # 時刻
  use Sinoa::Record;
  use Sinoa::Record::Bookmark;
  
  sub new {
    my $class = shift;
    my $self = {
      Record => Sinoa::Record->new( Sinoa::Record::Bookmark->filedir() ),
    };
    return bless $self,$class;
  }
  
  sub create {
    my ($self,$data) = @_;
    # こういうところにバリデーション書いてもいいかもね
    $data->[4] = _now();
    my $bookmark = Sinoa::Record::Bookmark->new($data);
    $self->{Record}->open(1)->add($bookmark->Name,$bookmark)->close();
  }
  
  sub remove {
    my ($self,$data) = @_;
    my $obj = $self->{Record}->open(1);
    $obj->delete($_) for @$data;
    $obj->close();
  }
  
  sub _now {
    my $t = localtime();
    return $t->year.'/'.$t->mon.'/'.$t->mday.' '.$t->hour.':'.$t->min.':'.$t->sec;
  }
  
  sub get_bookmark {
    my ($self,$args) = @_;
    my $bookmark = $self->{Record}->open;
    my $sum = @{$bookmark->get_list()};
    my %page = (
      switch => $args->{switch} // 10,
      current => $args->{no} - 1 // 0,
      limit => int(@{$bookmark->get_list()} / $args->{switch} + 0.99), # 数が大きくなりすぎた時にバグる
    );
    my %hash = %{$bookmark->get_alldata()};
    my @tmp = map { $hash{$_} } sort(keys %hash);
    my @bookmark = map {
      $tmp[$_] ? $tmp[$_] : ()
    } $page{current} * $page{switch}..$page{current} * $page{switch} + $page{switch} - 1;
    return \@bookmark,\%page;
  }
  
}

1;
