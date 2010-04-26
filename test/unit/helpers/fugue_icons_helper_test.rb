require 'test_helper'

class FugueIconsHelperTest < ActionView::TestCase
  context "Fugue Icon image tag generator" do
    should "return an image tag for the given icon name" do
      assert_equal %(<img class="fugue-icon" src="/images/icons-shadowless/mail.png" />), icon_tag("mail")
    end

    should "return an image tag for icons with shadows" do
      assert_equal %(<img class="fugue-icon" src="/images/icons/mail.png" />), icon_tag("mail", :shadow => true)
    end
    
    should "return an image tag for icons with an overlay" do
      assert_equal %(<img class="fugue-icon" src="/images/icons-shadowless/_overlay/mail--pencil.png" />), icon_tag("mail", :overlay => "pencil")
    end
    
    should "accept additional class definitions for the tag" do
      assert_equal %(<img class="fugue-icon other classes" src="/images/icons-shadowless/mail.png" />), icon_tag("mail", :class => "other classes")
    end

    should "accept other arbitrary attributes for the tag" do
      assert_equal %(<img class="fugue-icon" id="my_id" src="/images/icons-shadowless/mail.png" />), icon_tag("mail", :id => "my_id")
    end
  end
end