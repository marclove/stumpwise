class Manage::SitesController < ApplicationController
  layout 'manage'
  skip_before_filter :handle_invalid_site
  before_filter :require_administrator
  before_filter :get_site, :except => [:index, :new, :create]

  def index
    @sites = Site.all(:order => "created_at DESC")
  end
  
  def new
    @site = Site.new
    @user = User.new
  end
  
  def create
    @site = Site.new(params[:site])
    @user = User.new(params[:user])
    
    User.transaction do
      Site.transaction do
        @user_saved = @user.save
        @site = @user.owned_sites.build(params[:site])
        @site_saved = @site.save
        @administratorship_created = Administratorship.create(:site => @site, :administrator => @user)
      end
    end
    
    if @user_saved && @site_saved && @administratorship_created
      redirect_to manage_sites_path
    else
      flash.now[:error] = t("site.create.fail")
      render :action => 'new'
    end
  end
  
  def edit
  end
  
  def update
    if @site.update_attributes(params[:site])
      flash[:notice] = t("site.update.success")
      redirect_to manage_sites_path
    else
      flash.now[:error] = t("site.update.fail")
      render :action => 'edit'
    end
  end
  
  def destroy
    if @site.destroy
      flash[:notice] = t("site.destroy.success")
      redirect_to manage_sites_path
    else
      flash[:error] = t("site.destroy.fail")
      redirect_to :back
    end
  end
  
  private
    def get_site
      @site = Site.find(params[:id], :include => :owner)
    end
end
