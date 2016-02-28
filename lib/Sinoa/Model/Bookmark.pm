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
  
  sub _now {
    my $t = localtime();
    return $t->year.'/'.$t->mon.'/'.$t->mday.' '.$t->hour.':'.$t->min.':'.$t->sec;
  }
  
  sub get_bookmark {
    my ($self,$args) = @_;
    my $page = $args->{page} // 1;
    my $limit = $args->{limit} // 10;
    my %bookmark = %{$self->{Record}->open->get_alldata()};
    my @middle = map { $_ } sort(values %bookmark);
    my @result = map { $middle[$_] ? $middle[$_] : () } ($page-1)*$limit..$page*$limit;
    return \@result,$page;
  }
  
}

1;
