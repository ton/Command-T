# Copyright 2010-2011 Wincent Colaiuta. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

require 'command-t/ext' # CommandT::Matcher
require 'command-t/vim/path_utilities'

module CommandT
  # Encapsulates a Scanner instance (which builds up a list of available files
  # in a directory) and a Matcher instance (which selects from that list based
  # on a search string).
  #
  # Specialized subclasses use different kinds of scanners adapted for
  # different kinds of search (files, buffers).
  class Finder
    include VIM::PathUtilities

    def initialize path = Dir.pwd, options = {}
      raise RuntimeError, 'Subclass responsibility'
    end

    # Options:
    #   :limit (integer): limit the number of returned matches
    def sorted_matches_for str, options = {}
      @matcher.sorted_matches_for str, options
    end

    def flush
      @scanner.flush
    end

    def open_selection command, selection, options = {}
        # Default implementation, children can re-implement this at their leisure.
        
        selection = File.expand_path selection, @path
        selection = relative_path_under_working_directory selection
        selection = sanitize_path_string selection
        
        ::VIM::command "silent #{command} #{selection}"
    end

    def path= path
      @scanner.path = path
    end
  
    
  private
  
    # Backslash-escape space, \, |, %, #, "
    def sanitize_path_string str
      # for details on escaping command-line mode arguments see: :h :
      # (that is, help on ":") in the Vim documentation.
      str.gsub(/[ \\|%#"]/, '\\\\\0')
    end
  end # class Finder
end # CommandT
