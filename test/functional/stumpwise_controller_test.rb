require 'test_helper'

class StumpwiseControllerTest < ActionController::TestCase
  context "for an inactive site on GET to :show" do
    setup do
      setup_session_domain
      on_site(:inactive)
      get :show, :path => []
    end
    
    should_respond_with(404)
  end  
    
  context "for site with content on GET to :show with a path" do
    setup do
      setup_session_domain
      on_site(:with_content)
    end
    
    context "that is empty (the site root)" do
      setup { get :show, :path => [] }
      should_respond_with :success
      should_assign_to(:item){ items(:news_blog) }
      should_assign_to :articles
    end
    
    context "for a page that is published" do
      setup { get :show, :path => ["about"] }
      should_respond_with :success
      should_assign_to(:item){ items(:about_page) }
    end
    
    context "for a page that is unpublished" do
      setup { get :show, :path => ["unpublished-page"] }
      should_respond_with :missing
    end
    
    context "for a blog that is published" do
      setup { get :show, :path => ["news"] }
      should_respond_with :success
      should_assign_to(:item){ items(:news_blog) }
      should_assign_to :articles
    end
    
    context "for a blog that is unpublished" do
      setup { get :show, :path => ["unpublished-blog"] }
      should_respond_with :missing
    end
    
    context "for an article that is published belonging to a blog that is published" do
      setup { get :show, :path => ["news", "news-blog-article-1"] }
      should_respond_with :success
      should_assign_to(:item){ items(:news_blog_article_1) }
    end
    
    context "for an article that is published belonging to a blog that is unpublished" do
      setup { get :show, :path => ["unpublished-blog", "published-article"] }
      should_eventually "respond with :missing"
      #should_respond_with :missing
    end
    
    context "for an article that is unpublished" do
      setup { get :show, :path => ["news", "unpublished-article"]}
      should_respond_with :missing
    end
    
    context "for an item that does not exist" do
      setup { get :show, :path => ["nonexistent"]}
      should_respond_with :missing
    end
  end
  
  context "for site without content on GET to :show with any path" do
    setup do
      setup_session_domain
      on_site(:without_content)
      get :show, :path => []
    end
    should_respond_with :missing
  end
end
