require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  context "An article" do
    should_belong_to :blog
    should_validate_presence_of :parent_id # for blog relationship
    should_have_readonly_attributes :show_in_navigation
    should_validate_presence_of :body
    
    should "know its liquid name" do
      assert_equal "article", Article.new.liquid_name
    end
    
    should "inherit its site_id from its blog" do
      article = items(:blog).articles.create(:title => "Test Article", :body => "Article body")
      assert_equal article.site_id, items(:blog).site_id
    end

    should "be able to be transformed into a liquid drop" do
      assert_instance_of ArticleDrop, Article.new.to_liquid
    end

    should_eventually "return its template"
  end  
end
