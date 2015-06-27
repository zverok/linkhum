# coding: utf-8
require 'bundler/setup'
require 'linkhum'

namespace :dev do
  desc "Run all the examples and compile them to single HTML file to check"
  task :examples do
    require 'yaml'
    require 'fileutils'
    
    out = ''
    out << '<html><head><meta charset="utf-8"></head><body><dl>'
    YAML.load(File.read('spec/fixtures/examples.yml')).each do |ex|
      out << "<dt><tt>#{CGI.escapeHTML(ex['text'])}</tt></dt>"
      out << "<dd>#{LinkHum.urlify(ex['text'])}</dd>"
    end
    out << '</dl></body></html>'
    FileUtils.mkdir_p 'tmp'
    File.write 'tmp/examples.html', out
    puts "Written, check tmp/examples.html"
  end
end
