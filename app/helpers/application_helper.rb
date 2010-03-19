# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def flash_messages
    unless error_flash.blank? && notice_flash.blank?
      content_tag :div, :id => 'flash_messages' do
        error_flash + notice_flash
      end
    end
  end
  
  def typekit
    html = <<-EOF
      <script type="text/javascript" src="http://use.typekit.com/yoc5bbm.js"></script>
    	<script type="text/javascript">try{Typekit.load();}catch(e){}</script>
    EOF
  end
  
  def clippy(text, bgcolor='#FFFFFF')
    html = <<-EOF
      <object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000"
              width="126"
              height="16"
              id="clippy" >
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
             bgcolor="#{bgcolor}"
      />
      </object>
    EOF
  end
  
  private
    def error_flash
      if flash[:error]
        content_tag :p, flash[:error], {:id => 'error', :class => 'flash_message'}
      else
        ''
      end
    end

    def notice_flash
      if flash[:notice]
        content_tag :p, flash[:notice], {:id => 'notice', :class => 'flash_message'}
      else
        ''
      end
    end
end
