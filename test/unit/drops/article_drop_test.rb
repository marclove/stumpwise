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