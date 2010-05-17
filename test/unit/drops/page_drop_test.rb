require 'test_helper'

class PageDropTest < ActiveSupport::TestCase
  context "Page Drop" do
    setup do
      @page_drop = items(:about_page).to_liquid
    end
    
    should "have an id attribute" do
      assert_equal 12, @page_drop['id']
    end
    
    should "have a body attribute" do
      assert_equal "About page body", @page_drop['body']
    end
    
    should "have an html id attribute" do
      assert_equal "page-12", @page_drop['html_id']
    end
  end
end