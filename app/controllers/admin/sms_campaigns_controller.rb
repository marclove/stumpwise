class Admin::SmsCampaignsController < ApplicationController
  def index
    @sms_campaigns = current_site.sms_campaigns
    @sms_campaign  = SmsCampaign.new
  end
  
  def create
    @sms_campaign = current_site.sms_campaigns.build(params[:sms_campaign])
    if @sms_campaign.save && @sms_campaign.send_campaign!
      flash[:notice] = t('sms_campaign.create.success')
      redirect_to admin_sms_campaigns_path
    else
      @sms_campaigns = current_site.sms_campaigns
      flash.now[:error] = t('sms_campaign.create.fail')
      render :action => 'index'
    end
  end
end
