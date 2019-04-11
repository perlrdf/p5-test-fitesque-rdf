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
#use Test::FITesque::Test;
use Types::Namespace qw(Namespace);
use Types::Path::Tiny qw(Path);
use Data::Dumper;

use parent 'Test::FITesque::Test';
#extends 'Test::FITesque::Test';

has source => (
					is      => 'ro',
					isa     => Path, # TODO: Generalize to URLs
					required => 1,
					coerce  => 1,
				  );


sub transform_rdf {
  my $self = shift;
  my $ns = URI::NamespaceMap->new(['deps', 'dc']);
  $ns->add_mapping(test => 'http://example.org/test-fixtures#'); # TODO: Get a proper URI
  my $parser = Attean->get_parser(filename => $self->source)->new();
  my $model = Attean->temporary_model;
  $model->add_iter($parser->parse_iter_from_io( $self->source->openr_utf8 )->as_quads(iri('http://example.org/graph'))); # TODO: Use a proper URI for graph

  my $tests_uri_iter = $model->objects(undef, iri($ns->test->fixtures->as_string)); # TODO: Implement coercions in Attean

  my @data;
  
  while (my $test_uri = $tests_uri_iter->next) {
	 my $params_base = URI::Namespace->new($model->objects($test_uri, iri($ns->test->param_base->as_string))->next);
	 $ns->guess_and_add($params_base);
	 my $handler = $model->objects($test_uri, iri($ns->test->handler->as_string))->next;
	 push(@data, [$handler->value]);
	 my $id = $model->objects($test_uri, iri($ns->dc->identifier->as_string))->next;
	 my $expects_iter = $model->objects($test_uri, iri($ns->test->expects->as_string));
	 while (my $expect_sub = $expects_iter->next) {
		my $expectations_iter = $model->get_quads($expect_sub);
		my $params;
		while (my $expect = $expectations_iter->next) {
		  my $param = $params_base->local_part($expect->predicate);
		  my $value = $expect->object->value;
		  $params->{$param} = $value;
		}
		push(@data, [$id->value, $params])
	 }
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

