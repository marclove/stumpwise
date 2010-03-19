class Admin::SitesController < ApplicationController
  def edit
    @site = current_site
  end
  
  def update
    @site = current_site
    if @site.update_attributes(params[:site])
      flash[:notice] = t("site.update.success")
      redirect_to :action => 'edit', :id => @site.id
    else
      flash[:error] = t("site.update.fail")
      render :action => 'edit'
    end
  end
end
