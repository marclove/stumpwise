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

class Admin::PagesController < AdminController
  before_filter :get_page, :except => [:index, :new, :create]

  def index
    @pages = current_site.pages
  end

  def new
    @page = Page.new(:show_in_navigation => true, :published => true)
  end

  def create
    @page = Page.new(params[:page])
    @page.site_id = current_site.id
    if @page.save
      flash[:notice] = t("page.create.success")
      redirect_to admin_pages_path
    else
      flash.now[:error] = t("page.create.fail")
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @page.update_attributes(params[:page])
      flash[:notice] = t("page.update.success")
      redirect_to admin_pages_path
    else
      flash.now[:error] = t("page.update.fail")
      render :action => 'edit'
    end
  end
  
  def publish
    @page.update_attributes(:published => true) if @page
  end
  
  def unpublish
    @page.update_attributes(:published => false) if @page
  end
  
  def destroy
    @page.destroy if @page
    redirect_to admin_pages_path
  end
  
  private
    def get_page
      @page = current_site.pages.find(params[:id])
    end
end
