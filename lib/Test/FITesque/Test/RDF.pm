use 5.010001;
use strict;
use warnings;

package Test::FITesque::Test::RDF;

our $AUTHORITY = 'cpan:KJETILK';
our $VERSION   = '0.001';

use Moo;
use Attean::RDF;
use Path::Tiny;
use URI::NamespaceMap;
use Test::FITesque::Test;
use Types::Standard qw(InstanceOf);
use Types::Namespace qw(Namespace);
use Types::Path::Tiny qw(Path);
use Data::Dumper;

has source => (
					is      => 'ro',
					isa     => Path, # TODO: Generalize to URLs
					required => 1,
					coerce  => 1,
				  );

has suite => (
				  is => 'lazy',
				  isa => InstanceOf['Test::FITesque::Suite'],
				 );

sub _build_suite {
  my $self = shift;
  my $suite = Test::FITesque::Suite->new();
  foreach my $test (@{$self->transform_rdf}) {
	 $suite->add(Test::FITesque::Test->new({ data => $test}));
  }
  return $suite;
}



sub transform_rdf {
  my $self = shift;
  my $ns = URI::NamespaceMap->new(['deps', 'dc']);
  $ns->add_mapping(test => 'http://example.org/test-fixtures#'); # TODO: Get a proper URI
  my $parser = Attean->get_parser(filename => $self->source)->new();
  my $model = Attean->temporary_model;

  my $graph_id = iri('http://example.org/graph'); # TODO: Use a proper URI for graph
  $model->add_iter($parser->parse_iter_from_io( $self->source->openr_utf8 )->as_quads($graph_id));

  my $tests_uri_iter = $model->objects(undef, iri($ns->test->fixtures->as_string)); # TODO: Implement coercions in Attean
  # TODO: Support rdf:List here
  my @data;

  while (my $test_uri = $tests_uri_iter->next) {
	 my @instance;
	 my $params_base = URI::Namespace->new($model->objects($test_uri, iri($ns->test->param_base->as_string))->next);
	 $ns->guess_and_add($params_base);
	 my $test_bgp = bgp(triplepattern($test_uri, iri($ns->test->handler->as_string), variable('handler')),
							  triplepattern($test_uri, iri($ns->dc->identifier->as_string), variable('method')),
							  triplepattern($test_uri, iri($ns->test->params->as_string), variable('paramid')));

	 my $algebra = Attean::Algebra::Query->new(children => [$test_bgp]); # TODO: generalize the next 4 lines in Attean
	 my $planner = Attean::IDPQueryPlanner->new();
	 my $plan = $planner->plan_for_algebra($algebra, $model, $graph_id);
	 my $test_iter = $plan->evaluate($model); # Each row will correspond to one test

	 while (my $test = $test_iter->next) {
		push(@instance, [$test->value('handler')->value]);
		my $method = $test->value('method')->value;
		my $params_iter = $model->get_quads($test->value('paramid')); # Get the parameters for each test
		my $params;
		while (my $param = $params_iter->next) {
		  my $key = $params_base->local_part($param->predicate);
		  my $value = $param->object->value;
		  $params->{$key} = $value;
		}
		push(@instance, [$method, $params])
	 }
	 push(@data, \@instance);
  }
  return \@data;
}

1;

__END__

=pod

=encoding utf-8

=head1 NAME

Test::FITesque::Test::RDF - Formulate Test::FITesque fixture tables in RDF

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 BUGS

Please report any bugs to
L<https://github.com/kjetilk/p5-test-fitesque-rdf/issues>.

=head1 SEE ALSO

=head1 AUTHOR

Kjetil Kjernsmo E<lt>kjetilk@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is Copyright (c) 2019 by Inrupt Inc.

This is free software, licensed under:

  The MIT (X11) License


=head1 DISCLAIMER OF WARRANTIES

THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.

