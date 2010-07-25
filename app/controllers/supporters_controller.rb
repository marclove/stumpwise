class SupportersController < ApplicationController
  before_filter :handle_invalid_site, :reject_inactive_site
  
  def create
    supporter = params[:supporter]
    if supporter[:email]
      @supporter = Supporter.find_or_create_by_email(supporter[:email])
    elsif supporter[:mobile_phone]
      @supporter = Supporter.find_or_create_by_mobile_phone(supporter[:mobile_phone])
    end

    if @supporter
      supporter = supporter.delete_if{|k,v| v.blank?} # remove blank keys
      @supporter.update_attributes(supporter)
      
      @supportership = Supportership.find_or_create_by_supporter_id_and_site_id(
        :supporter_id => @supporter.id,
        :site_id => current_site.id,
        :receive_email => !(@supporter.email.blank?),
        :receive_sms => !(@supporter.mobile_phone.blank?)
      )
      # supportership = params[:supportership].delete_if{|k,v| v.blank?} # remove blank keys
      # @supportership.update_attributes(supportership)
      flash[:notice] = t('supporter.create.success')
    else
      flash[:error] = t('supporter.create.fail')
    end

    redirect_to :back
  end
end
