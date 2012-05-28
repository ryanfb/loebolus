#!/usr/bin/env ruby

require 'rubygems'
require 'yaml'
require 'rdf'
require 'rdf/rdfxml'

associations = YAML::load STDIN

RDF::Writer.open("example.rdf") do |writer|
  writer << RDF::Graph.new do |graph|
    associations.each_pair do |key,value|
      resource = RDF::Resource.new("http://s3.amazonaws.com/loebolus/#{key}.rdf")
      graph << [resource, RDF::DC.isPartOf, RDF::Resource.new("http://ryanfb.github.com/loebolus/")]
      if associations[key].include?('title')
        graph << [resource, RDF::DC.title, associations[key]['title']]
      end
      %w{archive openlibrary google}.each do |relation|
        if associations[key].include?(relation)
          graph << [resource, RDF::DC.relation, RDF::Resource.new(associations[key][relation])]
        end
      end
    end
  end
end
