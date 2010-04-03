class Admin::PagesController < ApplicationController
  before_filter :require_authorized_user
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
      flash[:error] = t("page.create.fail")
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
      flash[:error] = t("page.update.fail")
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
