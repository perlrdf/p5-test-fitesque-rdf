package Internal::Fixture::Simple;
use 5.010001;
use strict;
use warnings;
use parent 'Test::FITesque::Fixture';
use Test::More ;

sub string_found : Test : Plan(2) {
  my ($self, %args) = @_;
  use Data::Dumper;
  warn Dumper(\%args);
  ok(defined($args{all}), 'String exists');
  like($args{all}, qr/dahut/, 'Has a certain keyword');
}

1;

