#!/usr/bin/env ruby

require 'rubygems'
require 'yaml'
require 'rdf'
require 'rdf/vocab'
require 'rdf/rdfxml'
require 'rexml/document'

associations = YAML::load STDIN

formatter = REXML::Formatters::Pretty.new(2, true)
formatter.compact = true

root_url = "https://ryanfb.xyz/loebolus/"
root_resource = RDF::Resource.new(root_url)

File.open('index.rdf','w') do |file|
  rdf_xml = RDF::RDFXML::Writer.buffer do |writer|
    writer << RDF::Graph.new do |graph|
      associations.sort.map do |key,value|
        graph << [root_resource, RDF::Vocab::DC.hasPart, RDF::Resource.new("#{root_url}#{key}.rdf")]
      end
    end
  end
  rexml_rdf = REXML::Document.new(rdf_xml)
  file.puts "<?xml version='1.0' encoding='utf-8' ?>"
  file.puts(formatter.write(rexml_rdf.root,''))
end

associations.sort.map do |key,value|
  File.open("#{key}.rdf",'w') do |file|
    rdf_xml = RDF::RDFXML::Writer.buffer do |writer|
      writer << RDF::Graph.new do |graph|
        resource = RDF::Resource.new("#{root_url}#{key}.rdf")
        graph << [resource, RDF::Vocab::DC.isPartOf, root_resource]
        graph << [resource, RDF::Vocab::DC.source, RDF::Resource.new("https://ryanfb.xyz/loebolus-data/#{key}.pdf")]
        if associations[key].include?('title')
          graph << [resource, RDF::Vocab::DC.title, associations[key]['title']]
        end
        %w{archive openlibrary google}.each do |relation|
          if associations[key].include?(relation)
            graph << [resource, RDF::Vocab::DC.relation, RDF::Resource.new(associations[key][relation])]
          end
        end
      end
    end
    rexml_rdf = REXML::Document.new(rdf_xml)
    file.puts "<?xml version='1.0' encoding='utf-8' ?>"
    file.puts(formatter.write(rexml_rdf.root,''))
  end
end
