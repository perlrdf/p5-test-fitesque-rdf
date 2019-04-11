=pod

=encoding utf-8

=head1 PURPOSE

Unit test that Test::FITesque::Test::RDF transforms data correctly from RDF

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
my $t = Test::FITesque::Test::RDF->new(source => $file,
													param_ns => 'http://example.org/my-parameters#');

use Data::Dumper;
cmp_deeply($t->transform_rdf,
			  [ [ 'Internal::Fixture' ],
				 [ 'test_http_get',
					{
					 'uri' => 'https://inrupt.com/'
					}
				 ]
			  ]);


done_testing;

