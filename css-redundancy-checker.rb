#!/usr/bin/env ruby -wKU

require 'rubygems'
require 'open-uri'
require 'hpricot'

begin
  cssfile = ARGV[0]
  source = ARGV[1] 
  
  content = ""
  css_sourcefile = File.new(cssfile, "r")
  css_sourcefile.each_line {|line| content << line}

  # process our css file into a nice array of selectors
  content.gsub!(/\/\*.*?\*\//m, "") # strip the comments
  content.gsub!(/\{.*?\}/m, "") # strip the definitions
  content.gsub!(",", "\r\n") # one selector per line.
  content.gsub!(/^\s+$/, "") # strip lines containing just whitespace
  content.gsub!(/[\r\n]+/, "\n") # just one new line, thanks.
  content.gsub!(/:.*$/, "")
  selectors = content.split("\n").map {|s| s.strip}.uniq # no trailing whitespace in our array, please

  puts "Parsing all html files within #{source} for selectors in #{cssfile}..."
  puts "-------------"
  
  # Iterate over the html files to be parsed
  results = Hash.new
  
  things = []
  
  if File.directory?(source)
    things = Dir["#{source}/*.html"]
  elsif File.extname(source).eql?(".txt")
    file = File.new(source, "r")
    file.each_line {|line| things << line.strip}
  end
  
  things.each do |file|
    puts "Parsing #{file}"
    doc = Hpricot(open(file))
    # Iterate over each selector in cssfile and put the count of them into hash
    selectors.each do |selector|
      if results.has_key?(selector)
        results[selector] = results[selector] + doc.search(selector).size
      else
        results[selector] = doc.search(selector).size
      end
    end
  end
  
  puts "-------------"
  puts "The following selectors are NOT used in of the html files in #{source}"
  puts "-------------"
  
  # print all the selectors that are not used anywhere.
  results.sort_by {|sel, count| sel}.select {|sel, count| count.eql? 0}.each do |selector, count|
    puts selector
  end
  puts ""
rescue
  puts "Usage: css-redundancy-checker.rb [cssfile] [directory of html files OR .txt file listing urls to use]"
end
