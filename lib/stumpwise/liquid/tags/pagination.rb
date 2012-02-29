# Copyright (c) 2010-2011 ProgressBound, Inc.
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module Stumpwise
  module Liquid
    module Tags
      
      class Pagination < ::Liquid::Tag
        include ActionView::Helpers
        attr_accessor :output_buffer
        
        def initialize(name, markup, tokens)
          super
        end
        
        def render(context)
          if context['current_page']
            prev_content = link_to_if(context['previous_page'], "&laquo; Previous".html_safe, prev_link(context), :class => "prev_page") do
              content_tag :span, "&laquo; Previous".html_safe, :class => "prev_page disabled"
            end
            next_content = link_to_if(context['next_page'], "Next &raquo;".html_safe, next_link(context), :class => "next_page") do
              content_tag :span, "Next &raquo;".html_safe, :class => "next_page disabled"
            end
            content_tag :div, prev_content + next_content, :class => 'pagination'
          else
            ''
          end
        end
        
        def prev_link(context)
          url = "#{context['path']}?page=#{context['previous_page']}".html_safe
          url << "&amp;per_page=#{context['per_page']}".html_safe if context['per_page']
          url
        end
        
        def next_link(context)
          url = "#{context['path']}?page=#{context['next_page']}".html_safe
          url << "&amp;per_page=#{context['per_page']}".html_safe if context['per_page']
          url
        end
      end
    end
  end
end