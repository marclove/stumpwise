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
      
      # {% for item in items %}
      #   {% link_to item %}
      # {% end %}
      #
      # OR
      #
      # {% link_to '/issues/lgbt' %}
      class ItemLink < ::Liquid::Tag
        include ActionView::Helpers
        
        def initialize(name, markup, tokens)
          if match = markup.match(/\s*(#{::Liquid::QuotedString})/)
            @item_path = match[1][1..-2]
          elsif match = markup.match(/\s*(#{::Liquid::QuotedFragment})/) #markup =~ ::Liquid::Expression
            @item_name = match[1]
          else
            # TODO: Explain the proper syntax
            raise SyntaxError.new("Syntax Error in 'link_to'")
          end
          super
        end
        
        def render(context)
          if @item_name
            @item = context[@item_name]
          elsif @item_path
            @item = Item.find_by_permalink(@item_path).to_liquid
          end
          
          if @item
            @link_text = @link_text.to_s if @link_text
            content_tag(:a, @link_text || @item['title'], :href => @item['permalink'])
          else
            ''
          end
        end
      end
    end
  end
end