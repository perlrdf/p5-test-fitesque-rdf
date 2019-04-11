=pod

=encoding utf-8

=head1 PURPOSE

Integration tests using Test::FITesque::Test with RDF data to see tests actually working

=head1 AUTHOR

Kjetil Kjernsmo E<lt>kjetilk@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is Copyright (c) 2019 by Inrupt Inc.

This is free software, licensed under:

  The MIT (X11) License


=cut


use strict;
use warnings;

use Test::More;
use Path::Tiny;
use Data::Dumper;
use FindBin qw($Bin);
use Test::FITesque;
use Test::FITesque::Test;



package Internal::Fixture::Simple {
  use parent 'Test::FITesque::Fixture';
  use Test::More ;
  
  sub string_found : Test : Plan(2) {
	 my ($self, %args) = @_;
	 ok(defined($args{all}), 'String exists');
	 like($args{all}, qr/dahut/, 'Has a certain keyword');
  }

  1;
};

package Internal::Fixture::Multi {
  use parent 'Test::FITesque::Fixture';
  use Test::More ;
  
  sub multiplication : Test : Plan(4) {
	 my ($self, %args) = @_;
	 ok(defined($args{factor1}), 'Factor 1 exists');
	 ok(defined($args{factor2}), 'Factor 2 exists');
	 ok(defined($args{product}), 'Product parameter exists');
	 is($args{factor1} * $args{factor2}, $args{product}, 'Product is correct');
  }

  1;
};


my $file = $Bin . '/data/multi.ttl';


use_ok('Test::FITesque::Test::RDF');
my $rdft = Test::FITesque::Test::RDF->new(source => $file);
isa_ok($rdft, 'Test::FITesque::Test::RDF');

my @tests = map { Test::FITesque::Test->new({ data => $_ }) } @{$rdft->transform_rdf};
 
run_tests {
  @tests;
}
  

