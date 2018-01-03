#!/usr/bin/env ruby

require 'rubygems'
require 'nokogiri'
require 'yaml'
require 'net/https'
require 'uri'
require 'open-uri'

MAX_RETRIES = 0
ASSOCIATIONS_FILE = 'associations.yml'

def get_redirect(uri)
  url = URI.parse(uri)
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  res = http.start {|http|
    http.head(url.path)
  }
  res['location']
end

class Not200Error < StandardError
end

def is_200?(uri)
  retries = 0
  begin
    url = URI.parse(uri)
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.head(url.path)
    }
    $stderr.puts "#{res.code} for #{uri}"
    if res.code == '200'
      return true
    elsif retries < MAX_RETRIES
      raise Not200Error
    else
      return false
    end
  rescue Not200Error
    retries += 1
    sleep(retries)
    retry
  end
end

doc = Nokogiri::HTML(open('http://www.edonnelly.com/loebs.html'))

associations = {}
if File.exist?(ASSOCIATIONS_FILE)
  associations = YAML.load(File.read(ASSOCIATIONS_FILE))
end

doc.xpath('//td/a[contains(@href,"www.hup.harvard.edu/catalog/") and (text() != "HUP")]').to_a.uniq.each do |loeb|
  $stderr.puts "Checking:\n#{loeb.to_s}"
  title = loeb.xpath('following::td[1]').first.content
  original_title = loeb.xpath('following::td[1]/following::i[1]').first.content

  author = title.split(' -- ').first
  if author =~ /,/
    title = original_title
  else
    title = author + ' -- ' + original_title
  end

  loeb_number = loeb.content

  if is_200?("http://ryanfb.github.io/loebolus-data/#{loeb_number}.pdf")
    unless associations.has_key? loeb_number
      associations[loeb_number] ||= {}
      associations[loeb_number]['title'] ||= title
    end

    archive = loeb.xpath('following::a[text()="Archive"]').first
    google = loeb.xpath('following::a[text()="Google"]').first
    $stderr.puts "Got archive: #{archive.to_s}"
    $stderr.puts "Got google: #{google.to_s}"
    if archive && archive['href'] =~ /www\.archive\.org\//
      associations[loeb_number]['archive'] = archive['href']

      id = archive['href'].split('/').last
      associations[loeb_number]['openlibrary'] = get_redirect("https://openlibrary.org/ia/#{id}")
    end
    if google && google['href'] =~ /books\.google\.com\//
      associations[loeb_number]['google'] = google['href']
    end
  end
end

File.open(ASSOCIATIONS_FILE, 'w') do |file|
  file.write associations.to_yaml
end
