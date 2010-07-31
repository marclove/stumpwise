class SupportersController < ApplicationController
  layout nil
  before_filter :handle_invalid_site, :reject_inactive_site
  
  def new
    @supporter = Supporter.new
  end
  
  def create
    @supporter = Supporter.find_by_email(params[:supporter][:email]) || Supporter.create!(params[:supporter])
    Supportership.create!(
      :site => current_site,
      :supporter => @supporter,
      :receive_email => params[:receive_email],
      :receive_sms => params[:receive_sms]
    )
    respond_to do |format|
      format.html{ redirect_to current_site.root_url }
      format.js{ render :js => 'parent.Stumpwise.thankJoin();' }
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
