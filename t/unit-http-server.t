=pod

=encoding utf-8

=head1 PURPOSE

Unit test that Test::FITesque::RDF transforms HTTP data correctly from RDF when retrieving external content

=head1 AUTHOR

Kjetil Kjernsmo E<lt>kjetilk@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is Copyright (c) 2019 by Inrupt Inc.

This is free software, licensed under:

  The MIT (X11) License


=cut

use strict;
use warnings;

use Test::HTTP::MockServer;
 
my $server = Test::HTTP::MockServer->new();
my $url = $server->url_base();
 
my $handle_request_phase1 = sub {
    my ($request, $response) = @_;
    use Data::Dumper;
	 warn Dumper($response);
  };

$server->start_mock_server($handle_request_phase1);

my $ua = LWP::UserAgent->new;
my $content_response = $ua->get('/foo');


$server->stop_mock_server();


 
use Test::Modern;
use Test::Deep;
use FindBin qw($Bin);
use Data::Dumper;

my $s = My::WebServer->new;

my $url_root = $s->started_ok("start up my web server");

warn $url_root;

my $file = $Bin . '/data/http-list.ttl';

use Test::FITesque::RDF;


my $t = object_ok(
						sub { Test::FITesque::RDF->new(source => $file) }, 'RDF Fixture object',
						isa => [qw(Test::FITesque::RDF Moo::Object)],
						can => [qw(source suite transform_rdf)]);




my $data = $t->transform_rdf;

cmp_deeply($data,
[
          [
            [
              'Internal::Fixture::HTTPList'
            ],
            [
              'http_req_res_list_unauthenticated',
              {
					'-special' => {
										'http-pairs' => ignore(),
										'description' => 'More elaborate HTTP vocab for PUT then GET test'
									  },
              }
            ]
          ]
        ], 'Main structure ok');

my $params = $data->[0]->[1]->[1]->{'-special'};

is(scalar @{$params->{'http-pairs'}}, 2, 'There are two request-response pairs');

foreach my $pair (@{$params->{'http-pairs'}}) {
  object_ok($pair->{request}, 'Checking request object',
				isa => ['HTTP::Request'],
				can => [qw(method uri headers content)]
			  );
  object_ok($pair->{response}, 'Checking response object',
				isa => ['HTTP::Response'],
				can => [qw(code headers)]
			  );
}

is(${$params->{'http-pairs'}}[0]->{request}->method, 'PUT', 'First method is PUT');
is(${$params->{'http-pairs'}}[1]->{request}->method, 'GET', 'Second method is GET');

like(${$params->{'http-pairs'}}[0]->{request}->content, qr/dahut/, 'First request has content');


is(${$params->{'http-pairs'}}[0]->{response}->code, '201', 'First code is 201');
is(${$params->{'http-pairs'}}[1]->{response}->content_type, 'text/turtle', 'Second ctype is turtle');

cmp_deeply([${$params->{'http-pairs'}}[1]->{response}->header('Content-Type')], bag("text/turtle"), 'Response header field value bag comparison can be used for single values');
cmp_deeply([${$params->{'http-pairs'}}[1]->{response}->header('Accept-Post')], bag("text/turtle", "application/ld+json"), 'Response header field value bag comparison');

# TODO: Test retrieving content from URI

done_testing;

