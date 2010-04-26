module ApplicationHelper
  def typekit_scripts(account_id)
    html = <<-EOF
      <script type="text/javascript" src="http://use.typekit.com/#{account_id}.js"></script>
    	<script type="text/javascript">try{Typekit.load();}catch(e){}</script>
    EOF
  end
  
  def clippy(text, bgcolor='#FFFFFF')
    html = <<-EOF
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
  end
end
