class Admin::PagesController < ApplicationController
  def index
    @pages = current_site.pages
  end

  def new
    @page = Page.new
  end

  def create
    @page = Page.new(params[:page])
    @page.site_id = current_site.id
    if @page.save
      flash[:notice] = t("page.create.success")
      redirect_to admin_pages_path
    else
      flash[:error] = t("page.create.fail")
      render :action => 'new'
    end
  end

  def edit
    @page = current_site.pages.find(params[:id])
  end

  def update
    @page = current_site.pages.find(params[:id])
    if @page.update_attributes(params[:page])
      flash[:notice] = t("page.update.success")
      redirect_to admin_page_path(@page)
    else
      flash[:error] = t("page.update.fail")
      render :action => 'edit'
    end
  end
  
  def publish
    if @page = current_site.pages.find(params[:id])
      @page.update_attributes(:published => true)
    end
  end
  
  def unpublish
    if @page = current_site.pages.find(params[:id])
      @page.update_attributes(:published => false)
    end
  end
end
