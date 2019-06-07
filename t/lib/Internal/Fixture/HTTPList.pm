package Internal::Fixture::HTTPList;
use 5.010001;
use strict;
use warnings;
use parent 'Test::FITesque::Fixture';
use Test::More ;


sub http_req_res_list_unauthenticated : Test : Plan(6) {
  my ($self, $args) = @_;

  is(scalar @{$args->{'http-requests'}}, 2, 'There are two requests');
  is(${$args->{'http-requests'}}[0]->method, 'PUT', 'First method is PUT');
  is(${$args->{'http-requests'}}[1]->method, 'GET', 'Second method is GET');
  is(scalar @{$args->{'http-responses'}}, 2, 'There are two responses');
  is(${$args->{'http-responses'}}[0]->code, '201', 'First code is 201');
  is(${$args->{'http-responses'}}[1]->content_type, 'text/turtle', 'Second ctype is turtle');

}

1;

