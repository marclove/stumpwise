class SupportersController < ApplicationController
  layout nil
  before_filter :handle_invalid_site, :reject_inactive_site
  
  def new
    @supporter = Supporter.new
  end
  
  def create
    current_site.supporters.add(params[:supporter])
    respond_to do |format|
      format.html{ redirect_to current_site.root_url }
      format.js{ render :nothing => true }
    end
  rescue
    respond_to do |format|
      format.html do
        flash[:error] = t('supporter.create.fail')
        redirect_to :action => 'new'
      end
      format.js{ render :text => t('supporter.create.fail'), :status => :unprocessable_entity }
    end
  end
end
