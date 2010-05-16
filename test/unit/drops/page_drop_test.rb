require 'test_helper'

class PageDropTest < ActiveSupport::TestCase
  context "Page Drop" do
    setup do
      @page_drop = items(:about_page).to_liquid
    end
    
    should "have a body attribute" do
      assert_equal "About page body", @page_drop['body']
    end
  end
end