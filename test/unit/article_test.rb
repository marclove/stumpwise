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
