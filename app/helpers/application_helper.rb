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

module ApplicationHelper
  def typekit_scripts(account_id)
    result = <<-EOF
      <script type="text/javascript" src="http://use.typekit.com/#{account_id}.js"></script>
    	<script type="text/javascript">try{Typekit.load();}catch(e){}</script>
    EOF
    result.html_safe
  end
  
  def clippy(text, bgcolor='#FFFFFF')
    result = <<-EOF
      <object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000"
              width="126"
              height="16"
              class="clippy">
      <param name="movie" value="/flash/clippy.swf"/>
      <param name="allowScriptAccess" value="always" />
      <param name="quality" value="high" />
      <param name="scale" value="noscale" />
      <param name="FlashVars" value="text=#{text}">
      <param name="wmode" value="transparent">
      <param name="bgcolor" value="#{bgcolor}">
      <embed src="/flash/clippy.swf"
             width="126"
             height="16"
             name="clippy"
             quality="high"
             allowScriptAccess="always"
             type="application/x-shockwave-flash"
             pluginspage="http://www.macromedia.com/go/getflashplayer"
             FlashVars="text=#{text}"
             wmode="transparent"
             bgcolor="#{bgcolor}" />
      </object>
    EOF
    result.html_safe
  end
  
  def gridfs_image_tag(id, *args)
    return '' unless id.present?
    args.unshift("/gridfs/#{id}")
    image_tag(*args)
  end

  def timeago(time, options={})
    options.reverse_merge!({:format => :default, :class => 'timeago'})
    content_tag(:time, time.to_s(options.delete(:format)), options.merge(:datetime => time.getutc.iso8601)) if time
  end
end
