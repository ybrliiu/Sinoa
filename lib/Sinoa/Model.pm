package Sinoa::Model {
  
  use v5.14;
  use warnings;
  use utf8;
  
  use Sinoa::Model::Bookmark;
  
  sub new {
    my $class = shift;
    my $self->{'bookmark'} = Sinoa::Model::Bookmark->new();
    return bless $self,$class;
  }
  
  sub bookmark {
    my $self = shift;
    return $self->{'bookmark'};
  }
  
}

1;
