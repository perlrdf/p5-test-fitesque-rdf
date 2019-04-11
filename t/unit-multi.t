=pod

=encoding utf-8

=head1 PURPOSE

Unit test that Test::FITesque::Test::RDF transforms data correctly from RDF with multiple tests and multiple parameters

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
use Test::Deep;
use FindBin qw($Bin);


my $file = $Bin . '/data/simple.ttl';


use_ok('Test::FITesque::Test::RDF');
my $t = Test::FITesque::Test::RDF->new(source => $file);

use Data::Dumper;

my $data = $t->transform_rdf;
cmp_deeply($data,
			  [ [ 'Internal::Fixture::Simple' ],
				 [ 'string_found',
					{
					 'all' => 'counter-clockwise dahut'
					}
				 ]
			  ],
			  [ [ 'Internal::Fixture::Multi' ],
				 [ 'multiplication',
					{
					 'factor1' => '6',
					 'factor2' => '7',
					 'product' => '42'
					}
				 ]
			  ]


			 );


done_testing;

