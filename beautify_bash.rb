#!/usr/bin/ruby -w


=begin
/***************************************************************************
 *   Copyright (C) 2008, Paul Lutus                                        *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/
=end

PVERSION = "Version 1.2, 09/10/2009"

module BeautifyBash

   # user-customizable values

   BeautifyBash::TabStr = " "
   BeautifyBash::TabSize = 3

   def BeautifyBash.beautify_string(data,path)
      tab = 0
      case_count = 0
      case_stack = []
      case_stack[0] = 0
      in_here_doc = false
      defer_ext_quote = false
      in_ext_quote = false
      ext_quote_string = ""
      here_string = ""
      output = []
      data.each do |record|
         record.chomp!
         stripped_record = record.strip
         if(in_here_doc)
            if(stripped_record =~ %r{#{here_string}})
               in_here_doc = false
            end
         else # not in here_doc
            if(stripped_record =~ %r{<<-?})
               here_string = stripped_record.sub(%r{.*<<-?\s*['|"]?([_|\w]+)['|"]?.*},"\\1")
               in_here_doc = true if (here_string.size > 0)
               # puts "here string: [#{here_string}]"
            end
         end
         if(in_here_doc) # pass unchanged
            output << record
         else # not in here_doc
            test_record = stripped_record.gsub(/\\./,"")
            # collapse multiple quotes between ' ... '
            test_record = test_record.gsub(/'.*?'/,"")
            # collapse multiple quotes between " ... "
            test_record = test_record.gsub(/".*?"/,"")
            # remove '#' comments
            test_record = test_record.sub(/(\A|\s)(#.*)/,"")
            if(in_ext_quote)
               if(test_record =~ %r{#{ext_quote_string}})
                  # provide line after quote
                  test_record = test_record.sub(%r{.*#{ext_quote_string}(.*)},"\\1")
                  in_ext_quote = false
               end
            else # not in ext_quote
               if(test_record =~ %r{[^\\]('|")})
                  # apply only after this line has been processed
                  defer_ext_quote = true
                  ext_quote_string = test_record.sub(%r{.*(['|"]).*},"\\1")
                  # provide line before quote
                  test_record = test_record.sub(%r{(.*)#{ext_quote_string}.*},"\\1")
               end
            end
            if(in_ext_quote) # pass unchanged
               output << record
            else
               inc = test_record.scan(/(\s|\A|;)(case|then|do)(;|\Z|\s)/).length
               inc += test_record.scan(/(\{|\(|\[)/).length
               outc = test_record.scan(/(\s|\A|;)(esac|fi|done|elif)(;|\)|\||\Z|\s)/).length
               outc += test_record.scan(/(\}|\)|\])/).length
               if(test_record =~ /\besac\b/)
                  outc += case_stack[case_count]
                  case_count -= 1
               end
               # sepcial handling for bad syntax within case ... esac
               if(case_count > 0)
                  if(test_record =~ /\A[^(]*\)/)
                     # avoid overcount
                     outc -= 2;
                     case_stack[case_count] += 1
                  end
                  if test_record =~ /;;/
                     outc += 1
                     case_stack[case_count] -= 1
                  end
               end
               # an ad-hoc solution for the "else" keyword
               else_case = (test_record =~ /^(else)/)?-1:0
               net = inc - outc
               tab += (net < 0)?net:0
               extab = tab + else_case
               extab = (extab > 0)?extab:0
               output << (TabStr * TabSize * extab) + stripped_record
               tab += (net > 0)?net:0
            end # not in ext quote
            if(defer_ext_quote)
               in_ext_quote = true
               defer_ext_quote = false
            end # no deferred ext quote flag
            if(test_record =~ /\bcase\b/)
               case_count += 1
               case_stack[case_count] = 0
            end
         end # not in here doc
      end # each record
      error = (tab != 0)
      STDERR.puts "Error: indent/outdent mismatch: #{tab}." if error
      return output.join("\n") + "\n",error
   end # beautify_string

   def BeautifyBash.beautify_file(path)
      error = false
      if(path == '-') # stdin source
         source = STDIN.read
         dest,error = beautify_string(source,"stdin")
         print dest
      else # named file source
         source = File.read(path)
         dest,error = beautify_string(source,path)
         if(source != dest)
            # make a backup copy
            File.open(path + "~","w") { |f| f.write(source) }
            # overwrite the original
            File.open(path,"w") { |f| f.write(dest) }
         end
      end
      return error
   end # beautify_file

   def BeautifyBash.main
      error = false
      if(!ARGV[0])
         STDERR.puts "usage: shell script filenames or \"-\" for stdin."
         exit 0
      end
      ARGV.each do |path|
         error = (beautify_file(path))?true:error
      end
      error = (error)?1:0
      exit error
   end # main
end # module BeautifyBash

# if launched as a standalone program, not invoked as a module
if __FILE__ == $0
   BeautifyBash.main
end
