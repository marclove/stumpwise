require 'test_helper'

class BlogTest < ActiveSupport::TestCase
  context "A blog" do
    should_have_many :articles, :dependent => :destroy
    should_validate_presence_of :template_name
    should_validate_presence_of :article_template_name
    
    should "know its liquid name" do
      assert_equal "blog", Blog.new.liquid_name
    end
    
    should "have a default template name of blog.tpl on initialize" do
      assert_equal "blog.tpl", Blog.new.template_name
    end
    
    should "have a default article template name of article.tpl on initialize" do
      assert_equal "article.tpl", Blog.new.article_template_name
    end

    should "be able to be transformed into a liquid drop" do
      assert_instance_of BlogDrop, Blog.new.to_liquid
    end
    
    should_eventually "return its template"
  end  
end
