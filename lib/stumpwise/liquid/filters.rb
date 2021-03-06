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
    module Filters
      include ActionView::Helpers

      def simple_format(text)
        start_tag = tag('p', nil, true)
        text = text.to_s.dup
        text.gsub!(/\r\n?/, "\n")                    # \r\n and \r -> \n
        text.gsub!(/\n\n+/, "</p>\n\n#{start_tag}")  # 2+ newline  -> paragraph
        text.gsub!(/([^\n]\n)(?=[^\n])/, '\1<br />') # 1 newline   -> br
        text.insert 0, start_tag
        text.html_safe.safe_concat("</p>")
      end

      def textilize(text)
        RedCloth.new(text).to_html
      end
      
      def truncate(text, length)
        text, length = text.to_s, length.to_i
        super(text, :length => length)
      end
      
      def truncate_words(text, word_count=50, omission="...")
        text, word_count, omission = text.to_s, word_count.to_i, omission.to_s
        if text
          words = text.split(" ")
          text = words[0..(word_count.to_i - 1)]
          text = text.join(" ")
          text = "#{text}#{omission}" if words.size > word_count
          return text
        end
      end
      
      def image_tag(url, alt=nil, size=nil, mouseover=nil)
        return nil if url.blank?
        opts = {:src => url}
        opts[:alt] = alt if alt
        if size
          opts[:width], opts[:height] = size.split("x") if size =~ %{^\d+x\d+$}
        end
        if mouseover
          opts[:onmouseover] = "this.src='#{mouseover}'"
          opts[:onmouseout]  = "this.src='#{url}'"
        end
        tag(:img, opts)
      end
      
      def link_to_item(item, link_text=nil)
        link_text = link_text.to_s if link_text
        content_tag(:a, link_text || item['title'], :href => item['permalink'])
      end
      
      def feed_link_tag(item)
        if item.has_key?('feed_url')
          tag(:link, {:href => item['feed_url'], :rel => "alternate", :title => item['title'], :type => "application/atom+xml"})
        end
      end
      
      def widont(text)
        text = text.to_s
        text[text.rindex(" ")] = "&nbsp;"
        return text
      end
      
      def stylesheets(names, media="screen")
        sheets = names.split(",")
        sheets.inject("") do |result,s|
          result << tag(:link, {:media => media, :rel => "stylesheet", :type => "text/css", :href => asset_url("#{s}.css")})
        end
      end
      alias_method :stylesheet, :stylesheets
      
      def javascripts(names)
        scripts = names.split(",")
        scripts.inject("") do |result,s|
          result << content_tag(:script, "", {:type => "text/javascript", :src => asset_url("#{s}.js")})
        end
      end
      alias_method :javascript, :javascripts
      
      def asset_url(filename)
        path = []
        path << (Rails.env.production? ? "http://#{ThemeAssetUploader.s3_bucket}" : "http://s3.amazonaws.com/#{ThemeAssetUploader.s3_bucket}")
        path << "themes"
        path << @context.registers[:site].theme_id.to_s
        path << filename
        File.join(path)
      end
      
      def asset_image_tag(filename)
        image_tag(asset_url(filename), :alt => "")
      end
      
      def google_js(lib)
        lib = lib.to_s
        library, version = lib.split(".", 2)
        
        url = case library
          when "jquery"
            "http://ajax.googleapis.com/ajax/libs/jquery/#{version}/jquery.min.js"
          when "jqueryui"
            "http://ajax.googleapis.com/ajax/libs/jqueryui/#{version}/jquery-ui.min.js"
          when "prototype"
            "http://ajax.googleapis.com/ajax/libs/prototype/#{version}/prototype.js"
          when "scriptaculous"
            "http://ajax.googleapis.com/ajax/libs/scriptaculous/#{version}/scriptaculous.js"
          when "mootools"
            "http://ajax.googleapis.com/ajax/libs/mootools/#{version}/mootools-yui-compressed.js"
          when "dojo"
            "http://ajax.googleapis.com/ajax/libs/dojo/#{version}/dojo/dojo.xd.js"
          when "swfobject"
            "http://ajax.googleapis.com/ajax/libs/swfobject/#{version}/swfobject.js"
          when "yui"
            "http://ajax.googleapis.com/ajax/libs/yui/#{version}/build/yuiloader/yuiloader-min.js"
          when "ext-core"
            "http://ajax.googleapis.com/ajax/libs/ext-core/#{version}/ext-core.js"
          when "chrome-frame"
            "http://ajax.googleapis.com/ajax/libs/chrome-frame/#{version}/CFInstall.min.js"
          else nil
        end
        
        if !version.nil? && !url.nil?
          return content_tag(:script, "", :src => url, :type => "text/javascript")
        else
          return ""
        end
      end
      
      def index(array, i)
        array, i = array.to_a, i.to_i
        array[i]
      end
      
      def attribute(array, attribute)
        array, attribute = array.to_a, attribute.to_s
        array.map{ |i| i[attribute] }
      end
      
      def sort(array, attribute=nil)
        array = array.to_a
        attribute = attribute.to_s if attribute
        if attribute
          array.sort{ |x,y| x[attribute] <=> y[attribute] }
        else
          array.sort
        end
      end
      
      def split(string, split_on)
        string, split_on = string.to_s, split_on.to_s
        string.split(split_on)
      end
      
      def to_sentence(array)
        array = array.to_a
        array.to_sentence
      end
      
      def currency(number, precision=2, unit="$", delimiter=",", separator=".", format="%u%n")
        return nil if number.blank?
        return nil unless number.is_a?(Numeric)
        precision, unit, delimiter, separator, format = precision.to_i, unit.to_s, delimiter.to_s, separator.to_s, format.to_s
        number_to_currency(number, :precision => precision, :unit => unit, :delimiter => delimiter, :separator => separator, :format => format)
      end
      
      def readable_file_size(number)
        return nil if number.blank?
        return nil unless number.is_a?(Numeric)
        number_to_human_size(number)
      end
      
      def percentage(number, precision=2, delimiter=',', separator='.')
        return nil if number.blank?
        return nil unless number.is_a?(Numeric)
        precision, delimiter, separator = precision.to_i, delimiter.to_s, separator.to_s
        number_to_percentage(number, :precision => precision, :separator => separator, :delimiter => delimiter)
      end
      
      def delimiter(number, delimiter=",", separator=".")
        return nil if number.blank?
        return nil unless number.is_a?(Numeric)
        delimiter, separator = delimiter.to_s, separator.to_s
        number_with_delimiter(number, :delimiter => delimiter, :separator => separator)
      end
      
      def precision(number, precision=2, delimiter=",", separator=".")
        return nil if number.blank?
        return nil unless number.is_a?(Numeric)
        precision, delimiter, separator = precision.to_i, delimiter.to_s, separator.to_s
        number_with_precision(number, {:precision => precision, :delimiter => delimiter, :separator => separator})
      end
      
      def phone_number(number, area_code=false, delimiter="-")
        return nil if number.blank?
        area_code = false unless (area_code == true || area_code == false)
        delimiter = delimiter.to_s
        number_to_phone(number, {:area_code => area_code, :delimiter => delimiter})
      end
      
      def date(time, format_string)
        return nil unless (time.is_a?(String) || time.is_a?(Time))
        return nil if time.blank?
        time = time.is_a?(String) ? Time.parse(time) : time
        time.strftime(format_string)
      end
    end
  end
end