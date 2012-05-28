#!/usr/bin/env ruby

require 'rubygems'
require 'haml'
require 'yaml'

associations = YAML::load STDIN

template = IO.read(File.join('index.haml'))
haml_engine = Haml::Engine.new(template, :format => :html5)
open('index.html','w') {|file|
  file.write(haml_engine.render(Object.new, :associations => associations))
}
