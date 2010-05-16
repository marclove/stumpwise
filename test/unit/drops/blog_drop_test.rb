require 'test_helper'

class BlogDropTest < ActiveSupport::TestCase
  context "Blog Drop" do
    setup do
      @blog_drop = items(:news_blog).to_liquid
    end
  end
end