#!/usr/bin/env ruby

require 'rubygems'
require 'nokogiri'
require 'yaml'
require 'net/http'
require 'uri'
require 'open-uri'

def get_redirect(uri)
  url = URI.parse(uri)
  res = Net::HTTP.start(url.host, url.port) {|http|
    http.head(url.path)
  }
  res['location']
end

doc = Nokogiri::HTML(open('http://www.edonnelly.com/loebs.html'))

associations = {}

doc.xpath('//a[contains(@href,"books.google.com") or contains(@href,"www.archive.org")]').each do |link|
  loeb = link.xpath('preceding::a[contains(@href,"hup.harvard.edu")][2]').first
  title = loeb.xpath('following::td[1]').first.content
  loeb = loeb.content

  unless associations.has_key? loeb
    associations[loeb] = {}
    associations[loeb]['title'] = title
  end

  if link['href'] =~ /www.archive.org/
    associations[loeb]['archive'] = link['href']

    id = link['href'].split('/').last
    associations[loeb]['openlibrary'] = get_redirect("http://openlibrary.org/ia/#{id}")
  else
    associations[loeb]['google'] = link['href']
  end
end

puts associations.to_yaml
