require 'test_helper'

class BlogDropTest < ActiveSupport::TestCase
  context "Blog Drop" do
    setup do
      @blog_drop = items(:news_blog).to_liquid
    end
    
    should "have an id attribute" do
      assert_equal 9, @blog_drop['id']
    end
    
    should "have an html id attribute" do
      assert_equal "blog-9", @blog_drop['html_id']
    end
  end
end