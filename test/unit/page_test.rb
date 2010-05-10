require 'test_helper'

class PageTest < ActiveSupport::TestCase
  context "A page" do
    should_validate_presence_of :template_name, :body
    
    should "know its liquid name" do
      assert_equal "page", Page.make.liquid_name
    end
    
    should "have a default template name of page.tpl on initialize" do
      assert_equal "page.tpl", Page.new.template_name
    end

    should_eventually "return its template"
  end
end
