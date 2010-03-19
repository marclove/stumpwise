require 'test_helper'

class BlogTest < ActiveSupport::TestCase
  context "Blog:" do
    setup do
      @theme = Theme.create(:name => "theme")
      @site = Site.create(:subdomain => "my_site", :theme => @theme)
    end
  
    context "An instance of a Blog" do
      setup do
        @valid_attributes = {
          :title => "Test Blog Title",
          :theme_id => @theme.id,
          :site_id => @site.id
        }
        def new_blog(options={})
          Blog.new(@valid_attributes.merge(options))
        end
      end
      
      should "save with valid attributes" do
        assert_difference 'Blog.count' do
          blog = new_blog
          blog.save
          assert blog.errors.blank?
        end
      end
      
      should "require a template name" do
        assert_no_difference 'Blog.count' do
          blog = new_blog(:template_name => '')
          blog.save
          assert blog.errors.on(:template_name)
        end
      end
      
      should "require an article template name" do
        assert_no_difference 'Blog.count' do
          blog = new_blog(:article_template_name => '')
          blog.save
          assert blog.errors.on(:article_template_name)
        end
      end
      
      should "have many articles" do
        assert new_blog.respond_to?(:articles)
      end
    end
  end
end
