require 'test_helper'

class ArticleDropTest < ActiveSupport::TestCase
  context "Article Drop" do
    setup do
      @article_drop = items(:news_blog_article_1).to_liquid
    end
    
    should "have a body attribute" do
      assert_equal "The article body", @article_drop['body']
    end
    
    should "return its parent blog as a liquid drop" do
      assert @article_drop['blog'].is_a?(Liquid::Drop)
      assert_equal "News", @article_drop['blog']['title']
    end
  end
end