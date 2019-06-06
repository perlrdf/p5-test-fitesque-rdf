=pod

=encoding utf-8

=head1 PURPOSE

Unit test that Test::FITesque::RDF transforms HTTP data correctly from RDF

=head1 AUTHOR

Kjetil Kjernsmo E<lt>kjetilk@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is Copyright (c) 2019 by Inrupt Inc.

This is free software, licensed under:

  The MIT (X11) License


=cut

use strict;
use warnings;
use Test::Modern;
use Test::Deep;
use FindBin qw($Bin);
#use Carp::Always;
use Data::Dumper;

my $file = $Bin . '/data/http-list.ttl';

use Test::FITesque::RDF;


my $t = object_ok(
						sub { Test::FITesque::RDF->new(source => $file) }, '$t',
						isa => [qw(Test::FITesque::RDF Moo::Object)],
						can => [qw(source suite transform_rdf)]);




my $data = $t->transform_rdf;

#warn Dumper($data->[0]->[1]->[1]);
cmp_deeply($data,
[
          [
            [
              'Internal::Fixture::HTTPList'
            ],
            [
              'http_req_res_list_unauthenticated',
              {
                'http-requests' => ignore(),
                'http-responses' => ignore()
              }
            ]
          ]
        ], 'Main structure ok');

my $params = $data->[0]->[1]->[1];
#warn Dumper($params->{'http-requests'});

is(scalar @{$params->{'http-requests'}}, 2, 'There are two requests');

foreach my $req (@{$params->{'http-requests'}}) {
  object_ok($req, 'Checking request object',
				isa => ['HTTP::Request'],
				can => [qw(method uri headers)]
			  );
}





done_testing;

