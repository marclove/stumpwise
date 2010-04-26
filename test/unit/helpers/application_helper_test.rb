require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  context "Application Helper" do
    should "return script tags for Typekit" do
      expect = %(<script type="text/javascript" src="http://use.typekit.com/qwerty.js"></script><script type="text/javascript">try{Typekit.load();}catch(e){}</script>)
      assert_html_equal expect, typekit_scripts("qwerty")
    end
    
    should "return script tags for use with Clippy flash clipboard copying" do
      expect = <<-EOF
        <object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000"
                width="126"
                height="16"
                class="clippy">
        <param name="movie" value="/flash/clippy.swf"/>
        <param name="allowScriptAccess" value="always" />
        <param name="quality" value="high" />
        <param name="scale" value="noscale" />
        <param name="FlashVars" value="text=My test text goes here.">
        <param name="wmode" value="transparent">
        <param name="bgcolor" value="#112233">
        <embed src="/flash/clippy.swf"
               width="126"
               height="16"
               name="clippy"
               quality="high"
               allowScriptAccess="always"
               type="application/x-shockwave-flash"
               pluginspage="http://www.macromedia.com/go/getflashplayer"
               FlashVars="text=My test text goes here."
               wmode="transparent"
               bgcolor="#112233" />
        </object>
      EOF
      assert_html_equal expect, clippy("My test text goes here.", "#112233")
    end
  end
end