#!/usr/bin/env ruby -wKU
require "#{ENV['TM_SUPPORT_PATH']}/lib/escape"
require "shellwords"

# abort "Select one or more items in file browser" unless ENV.has_key? 'TM_SELECTED_FILES'

paths = Shellwords.shellwords(ENV['TM_SELECTED_FILES'])
tags  = paths.map { |path| "<img src='file://#{e_url path}'>\n" }
title = paths.size > 1 ? "Selected Images" : File.basename(paths.first)

puts "<html>\n<head><title>#{title}</title></head>\n<body><center>\n#{tags.join("<br>\n")}</center></body>\n</html>"