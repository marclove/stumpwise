# Copyright (c) 2010-2011 ProgressBound, Inc.
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'test_helper'

class StumpwiseControllerTest < ActionController::TestCase
  context "StumpwiseController" do
    setup do
      Site.any_instance.stubs(:template).returns([Liquid::Template.parse(""), {}])
    end
    
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
end
