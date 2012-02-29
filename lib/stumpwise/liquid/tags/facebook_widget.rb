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
      class FacebookWidget < ::Liquid::Tag
        def initialize(name, params, tokens)
          @attributes = {
            'stream' => 'false',
            'connections' => '6',
            'header' => 'true',
            'width' => '220',
            'height' => '290'
          }
          params.scan(::Liquid::TagAttributes) do |var, value|
            @attributes[var] = value
          end
        end
        
        def width
          @attributes['width'] == 'auto' ? "'auto'" : @attributes['width']
        end
        
        def render(context)
          if !context['site.facebook_page_id'].blank? && profile_id = context['site.facebook_page_id']
            profile_attribute = profile_id.integer? ? "id" : "name"
            result = <<-DIV
            <div id=\"facebook_widget\">
              <iframe src="http://www.facebook.com/plugins/likebox.php?#{profile_attribute}=#{profile_id}&amp;width=#{@attributes['width']}&amp;connections=#{@attributes['connections']}&amp;stream=#{@attributes['stream']}&amp;header=#{@attributes['header']}" scrolling="no" frameborder="0" allowTransparency="true" style="border:none; overflow:hidden; width:#{@attributes['width']}px; height:#{@attributes['height']}px;"></iframe>
            </div>
            DIV
          else
            result = ''
          end
          result.html_safe
        end
      end
    end
  end
end