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

class Admin::BlogsController < AdminController
  def index
    @blogs = current_site.blogs
    if @blogs.size < 1
      @page = params[:page] || 1
      @articles = current_site.articles.paginate(
        :per_page => 5,
        :page => @page,
        :order => 'created_at desc'
      )
    else
      redirect_to admin_blog_path(@blogs.first)
    end
  end
  
  def new
    @blog = Blog.new(:show_in_navigation => true, :published => true)
  end
  
  def create
    @blog = Blog.new(params[:blog])
    @blog.site_id = current_site.id
    if @blog.save
      flash[:notice] = t('blog.create.success')
      redirect_to admin_blog_path(@blog)
    else
      flash.now[:error] = t('blog.create.fail')
      render :action => 'new'
    end
  end
  
  def show
    @blogs = current_site.blogs
    @blog = current_site.blogs.find(params[:id])
    @page = params[:page] || 1
    @articles = @blog.articles.paginate(
      :per_page => 5,
      :page => @page,
      :order => 'created_at desc'
    )
  end
  
  def edit
    @blog = current_site.blogs.find(params[:id])
  end
  
  def update
    @blog = current_site.blogs.find(params[:id])
    if @blog.update_attributes(params[:blog])
      flash[:notice] = t('blog.update.success')
      redirect_to admin_blog_path(@blog)
    else
      flash.now[:error] = t('blog.update.fail')
      render :action => 'edit'
    end
  end
  
  def destroy
    @blog = current_site.blogs.find(params[:id])
    @blog.destroy
    redirect_to admin_blogs_path
  end
end
