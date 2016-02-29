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
    $data->[5] = time();
    my $bookmark = Sinoa::Record::Bookmark->new($data);
    $self->{Record}->open(1)->add($bookmark->Name,$bookmark)->close();
  }
  
  sub _now {
    my $t = localtime();
    return $t->year.'/'.$t->mon.'/'.$t->mday.' '.$t->hour.':'.$t->min.':'.$t->sec;
  }
  
  sub create_folder {
    my ($self,$name) = @_;
    $self->{Record}->open(1)->add($name,{})->close();
  }

  sub remove {
    my ($self,$data) = @_;
    my $obj = $self->{Record}->open(1);
    $obj->delete($_) for @$data;
    $obj->close();
  }
  
  sub get_bookmark {
    my ($self,$args) = @_;
    my $bookmark = $self->{Record}->open;
    my %page = (
      switch => $args->{switch} // 10, # 何件で切り替えるか
      current => $args->{no} - 1 // 0, # 表示するページ数
      limit => int(@{$bookmark->get_list()} / $args->{switch} + 0.99), # ページ数、数が大きくなりすぎた時にバグる
    );
    my @tmp = @{_sort($bookmark->get_alldata(),$args)};
    my @bookmark = map {
      $tmp[$_] ? $tmp[$_] : ()
    } $page{current} * $page{switch}..$page{current} * $page{switch} + $page{switch} - 1;
    return \@bookmark,\%page;
  }
  
  sub _sort {
    my ($bookmark,$option) = @_;
    my $like = sub {
      my ($key,$mode) = @_;
      $bookmark->{$key}->$mode =~ /$option->{'keyword'}/ ? $bookmark->{$key} : ();
    };
    my @result;
    if($option->{'name'} eq 'tag'){
      @result = map { $option->{'keyword'} eq $bookmark->{$_}->Tag ? $bookmark->{$_} : () } sort(keys %$bookmark);
    }elsif($option->{'name'} eq 'time'){
      @result = map { $bookmark->{$_} } sort { $bookmark->{$a}->Time <=> $bookmark->{$b}->Time }(keys %$bookmark);
    }elsif($option->{'name'} eq 'find'){
      @result = map { $like->($_,'Name') } sort(keys %$bookmark);
    }elsif($option->{'name'} eq 'url'){
      @result = map { $like->($_,'URL') } sort(keys %$bookmark);
    }else{
      @result = map { $bookmark->{$_} } sort(keys %$bookmark);
    }
    return \@result;
  }
  
}

1;