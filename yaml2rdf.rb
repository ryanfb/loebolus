#!/usr/bin/env ruby

require 'rubygems'
require 'yaml'
require 'rdf'
require 'rdf/rdfxml'

associations = YAML::load STDIN

root_url = "http://ryanfb.github.com/loebolus/"
root_resource = RDF::Resource.new(root_url)

RDF::Writer.open('index.rdf') do |writer|
  writer << RDF::Graph.new do |graph|
    associations.sort.map do |key,value|
      graph << [root_resource, RDF::DC.hasPart, RDF::Resource.new("#{root_url}#{key}.rdf")]
    end
  end
end

associations.sort.map do |key,value|
  RDF::Writer.open("#{key}.rdf") do |writer|
    writer << RDF::Graph.new do |graph|
      resource = RDF::Resource.new("#{root_url}#{key}.rdf")
      graph << [resource, RDF::DC.isPartOf, root_resource]
      graph << [resource, RDF::DC.source, RDF::Resource.new("http://ryanfb.github.io/loebolus-data/#{key}.pdf")]
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
