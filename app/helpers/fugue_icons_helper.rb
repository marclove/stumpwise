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

module FugueIconsHelper
  # Returns an html image tag for the fugue icon specified with <tt>name</tt>.
  # <tt>name</tt> should not include an overlay suffix or file extension.
  # 
  # ==== Options
  # * <tt>:shadow</tt> - If set to true, the path for icons with shadows will be used. Defaults to false.
  # * <tt>:overlay</tt> - The name of the overlay you want to use. Defaults to nil.
  def icon_tag(name, options={})
    options.symbolize_keys!

    options[:class] = if options[:class]
      "fugue-icon ".html_safe + options[:class]
    else
      "fugue-icon".html_safe
    end

    paths = options.delete(:shadow) ? ["icons".html_safe] : ["icons-shadowless".html_safe]
    if overlay = options.delete(:overlay)
      paths << "_overlay".html_safe
      name = "#{name}--#{overlay}".html_safe
    end
    paths << "#{name}.png".html_safe
    options[:src] = "/images/".html_safe + paths.join("/".html_safe)
    tag("img", options, false)
  end
end
