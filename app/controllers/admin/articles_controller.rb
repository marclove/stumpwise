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

class Admin::ArticlesController < AdminController
  before_filter :get_blog

  def new
    @article = @blog.articles.build(:published => true)
  end
  
  def create
    @article = @blog.articles.build(params[:article])
    @article.site_id = current_site.id
    if @article.save
      flash[:notice] = t("article.create.success")
      redirect_to admin_blog_path(@blog)
    else
      flash.now[:error] = t("article.create.fail")
      render :action => 'new'
    end
  end

  def edit
    @article = @blog.articles.find(params[:id])
  end
  
  def update
    @article = @blog.articles.find(params[:id])
    if @article.update_attributes(params[:article])
      flash[:notice] = t("article.update.success")
      redirect_to admin_blog_path(@blog)
    else
      flash.now[:error] = t("article.update.fail")
      render :action => 'edit'
    end
  end
  
=begin
  def publish
    if @article = @blog.articles.find(params[:id])
      @article.update_attributes(:published => true)
    end
  end
  
  def unpublish
    if @article = @blog.articles.find(params[:id])
      @article.update_attributes(:published => false)
    end
  end
=end
  
  def destroy
    @article = @blog.articles.find(params[:id])
    if @article.destroy
      flash[:notice] = t("article.destroy.success")
      redirect_to admin_blog_path(@blog)
    else
      flash.now[:error] = t("article.destroy.fail")
      render :action => 'edit'
    end
  end
  
  private
    def get_blog
      @blog = current_site.blogs.find(params[:blog_id])
    end
end
