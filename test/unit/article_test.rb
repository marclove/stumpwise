require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  context "Article:" do
    setup do
      @theme = Theme.create(:name => "theme")
      @site = Site.create(:subdomain => "my_site", :theme => @theme)
      @blog = Blog.create(:title => "Test Blog Title", :theme_id => @theme.id, :site_id => @site.id)
    end
  
    context "An instance of an Article" do
      setup do
        @valid_attributes = {
          :title => "Test Article Title",
          :theme_id => @theme.id,
          :site_id => @site.id,
          :blog_id => @blog.id
        }
        def new_article(options={})
          Article.new(@valid_attributes.merge(options))
        end
      end
      
      should "save with valid attributes" do
        assert_difference 'Article.count' do
          article = new_article
          article.save
          assert article.errors.blank?
        end
      end
      
      should "require a blog_id" do
        article = new_article(:blog_id => nil)
        article.valid?
        assert article.errors.on(:blog_id)
      end
      
      should "belong_to a blog" do
        assert_equal @blog, new_article.blog
      end
    end
  end
end
