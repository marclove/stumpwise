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
