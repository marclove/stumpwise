class Admin::AssetsController < ApplicationController
  before_filter :require_authorized_user, :require_acceptance_of_campaign_agreement

  def index
    @assets = current_site.assets
  end
  
  def new
    @asset = Asset.new
  end
  
  def create
    @asset = Asset.new(params[:asset])
    @asset.site_id = current_site.id
    if @asset.save
      flash[:notice] = t('asset.create.success')
      redirect_to admin_assets_path
    else
      flash.now[:error] = t('asset.create.fail')
      render :action => 'new'
    end
  end
  
  def destroy
    @asset = current_site.assets.find(params[:id])
    @asset.destroy
    redirect_to admin_assets_path
  end
end
