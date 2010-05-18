require 'test_helper'

class ArticleDropTest < ActiveSupport::TestCase
  context "Article Drop" do
    setup do
      @article_drop = items(:news_blog_article_1).to_liquid
    end
    
    should "have an id attribute" do
      assert_equal 10, @article_drop['id']
    end
    
    should "have a body attribute" do
      assert_equal "The article body", @article_drop['body']
    end
    
    should "return its parent blog as a liquid drop" do
      assert_equal items(:news_blog).to_liquid, @article_drop['blog']
    end
    
    should "have an html id attribute" do
      assert_equal "article-10", @article_drop['html_id']
    end
  end
end