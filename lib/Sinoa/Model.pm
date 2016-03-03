package Sinoa::Model {
  
  use Sinoa; # use v5.14,strict,warnings,utf8 & root_dir
  
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
