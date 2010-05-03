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
    @asset.save
    redirect_to :action => :index
  end
  
  def destroy
    @asset = Asset.find(params[:id])
    @asset.destroy
    redirect_to :back
  end
end
