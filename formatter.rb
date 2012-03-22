#!/usr/bin/env ruby
#a class for the formatter
class Formatter
	attr_reader :indenter, :backup, :debug_me
	def initialize(aHash={})
		@indenter = aHash[:space_count].nil? ? "	" : " "*aHash[:space_count].to_i
		@backup = aHash[:backup]
		@debug_me = aHash[:debug]
	end
	#kinda silly to not make format_text public
	def format_string(string)
		format_text(string)
	end
	#will take an array
	def format_file(file)
		file = [file] unless file.is_a?(Array)
		array_loc.each{|file_loc|
			f = File.open(file_loc,"r")
			text = f.read
			f.close
			new_text = format_text(text)
			FileUtils.cp("#{file_loc}","#{file_loc}.bk.#{Time.now}") if backup
			f = File.open("#{file_loc}","w+")
			f.puts new_text
			f.close
		}
		
	end
	private
	def format_text(string)
		new_text = ""
		current_depth = 0
		here_doc_ending = nil
		indenter =  @indenter
	
		#left over notes
		#these are how we change the depth 
		#outs = ["def","class","module","begin","case","if","unless","loop","while","until","for"]
		#both = ["elsif","else","when","rescue","ensure"]
		#ins = ["end","}"]
		#reset_depth = ["=begin"," = end"]
	
		temp_depth = nil
		line_count = 1
	
		string.split("\n").each{ |x|
			#comments
			#The first idea was to leave them alone.
			#after running a few test i did not like the way it looked
			if temp_depth
				puts "In temp_depth #{x} line ♯ #{line_count}" if debug_me
				new_text << x << "\n"
				#block comments, its going to get ugly
				unless x.lstrip.scan(/^\=end/).empty? || x.lstrip.scan(/#{here_doc_ending}/).empty?
					#swap and set
					puts "swap and set #{x} line # #{line_count}" if debug_me
					current_depth = temp_depth
					temp_depth = nil
					here_doc_ending = nil
				end
				
				next
			end
			#block will always be 0 depth
			#block comments, its going to get ugly
			unless x.lstrip.scan(/^\=begin/).empty?
				#swap and set
				puts "Looking for begin #{x} #{line_count}" if debug_me
				temp_depth = current_depth
				current_depth = 0
			end
			#here docs have same type of logic for block comments
			unless x.lstrip.scan(/<<-/).empty?
				#swap and set
				here_doc_ending = x.lstrip.scan(/<<-/).last.strip
				temp_depth = current_depth
			end
			#whats the first word?
			text_node = x.split.first || ""
	
			#check if its in end or both and that the current_depth is >0
			#maybe i should raise if it goes negative ?
			puts "minus one #{line_count} #{x} statement:#{(check_ends?(x) || in_both?(text_node)) && current_depth > 0} check_ends:#{check_ends?(x)} in_both:#{in_both?(text_node)}  current_depth:#{ current_depth }" if debug_me
			if (check_ends?(x) || in_both?(text_node))
				raise "We have a Negative depth count. This was caused around line:#{line_count}" if  current_depth < 0
				current_depth -= 1
			end
			clean_string = line_clean_up(x)
			current_indent = clean_string.size>0 ? indenter*current_depth : ""
			new_text << current_indent << clean_string << "\n"
	
	
			#we want to kick the indent out one
			#  x.match(/(unless|if).*(then).*end/): we use this match one liners for if statements not one-line blocks
			# in_outs? returns true if the first work is in the out array
			# in_both? does the same for the both array
			# start_block looks for to not have an end at the end and {.count > }.count and if the word do is in there
			# temp_depth is used when we hit the = comments should be nil unless you are in a comment
			puts "plus one match:#{line_count} #{x} match:#{!(x.match(/(unless|if).*(then).*end/))} or statements:#{(in_outs?(text_node) || in_both?(text_node) || start_block?(x))} in_outs#{in_outs?(text_node)} in_both:#{ in_both?(text_node)} start_block:#{ start_block?(x)} temp_depth:#{temp_depth}" if debug_me
			current_depth += 1 if !(x.match(/(unless|if).*(then).*end|(begin).*(rescue|ensure|else).*end/)) && ((in_outs?(text_node) || in_both?(text_node) || start_block?(x) || x.lstrip.slice(/\w*\s=\s(unless|if|case)/)) && !temp_depth)
			line_count += 1
		}
		new_text
	end
	
	#find if the string is a start block
	#return true if it is
	#rules
	# does not include end at the end
	# and ( { out number the } or it includes do 
	def start_block?(string)
		#if it has do and ends with end its a single line block
		# if we have more { then }  its the start of a block should raise if } is greater?
		#the crazy gsubs remove "{}" '{}' and /{}/  so string or regx wont be counted for blocks
		string = just_the_string_please(string)
		return true if  (!string.rstrip.slice(/end$/) && (string.scan("{").size>string.scan("}").size) || string.include?(" do"))
		false
	end
	#is this an end block?
	#rules
	#its not a one liner
	#and it ends with end
	#or } out number {
	def check_ends?(string)
		#check for one liners end and }
		string = just_the_string_please(string)
		return true if  (!(string.match(/(unless|if).*(then).*end/)) && (string.slice(/end$/) || string.slice(/end\swhile/) ))|| (string.scan("{").size < string.scan("}").size) 
		false
	end
	
	#look at first work does it start with one of the out works
	def in_outs?(string)
	
		["def","class","module","begin","case","if","unless","loop","while","until","for"].each{|x|
			if string.lstrip.slice(/^#{x}/)  && string.strip.size == x.strip.size
				return true
			end
		}
		false
	end
	#look at first work does it start with one of the both words?
	def in_both?(string)
		["elsif","else","when","rescue","ensure"].each{|x|
			return true if string.lstrip.slice(/^#{x}/) && string.strip.size == x.strip.size
		}
		false
	end
	#extra formatting for the line
	#we wrap = with spaces
	def line_clean_up(x)
		x = x.lstrip
		x = x.gsub(/[a-zA-Z\]\'\"{\d]+=[a-zA-Z\[\'\"{\d]+/){|x| x.split(" = ").join(" = ")}
		#or equal is failing to work in the same way
		#x = x.gsub(/[a-zA-Z\]\'\"{\d]+=[a-zA-Z\[\'\"{\d]+/){|x| x.split("||=").join(" ||= ")}
		x.strip! if x.strip.size == 0
		return x
	end
	
	def just_the_string_please(string)
		#remove regx first
		string = string.gsub(/\/.*\//,"")
		#then anything qouted 
		string = string.gsub(/"[^"]"/,"")
		string = string.gsub(/'[^']'/,"")
		#bye-bye comments
		string = string.gsub(/#.*/,'')
		#strip aways
		string = string.rstrip
		string = string.lstrip
		string
	end

end
#format_me = Formatter.new
#ruby_code =<<-RUBY
#def moo
#p ouch
#end
#RUBY
#puts format_me.format_string(ruby_code)