class ContributionsController < ApplicationController
  layout nil
  skip_before_filter :handle_invalid_site
  before_filter :get_site
  ssl_required :new, :create, :thanks
  filter_parameter_logging :number, :verification_value
  
  
  def new
    @contribution = Contribution.new
    @credit_card = ActiveMerchant::Billing::CreditCard.new
  end
  
  def create
    @contribution = @site.contributions.build(params[:contribution])
    @contribution.ip = request.ip
    @contribution.amount = contribution_amount

    @credit_card = ActiveMerchant::Billing::CreditCard.new(params[:credit_card])
    @credit_card.first_name = @contribution.first_name
    @credit_card.last_name = @contribution.last_name

    @contribution.valid? # Need to call this to ensure all errors are shown if @credit_card is invalid
    if @credit_card.valid? && @contribution.save
      response = @contribution.process(@credit_card)
      if response.success?
        flash[:notice] = t('contribution.process.success')
        redirect_to url_for(:subdomain => @site.subdomain, :controller => 'contributions', :action => 'thanks', :order_id => @contribution.order_id, :only_path => true, :secure => true)
      else
        flash.now[:error] = "#{t('contribution.process.fail.rejected')} #{response.message}"
        render :action => 'new'
      end
    else
      flash.now[:card_error] = t('contribution.process.fail.invalid_card') unless @credit_card.valid?
      flash.now[:error] = t('contribution.process.fail.invalid_record')
      render :action => 'new'
    end
  end
  
  def thanks
    @contribution = Contribution.find_by_order_id(params[:order_id])
  end
  
  private
    def get_site
      unless @site = Site.find_by_subdomain(params[:subdomain])
        render :file => 'public/404.html', :status => 404
      end
    end
    
    def contribution_amount
      @amount_choice = params[:amount_choice]
      @amount_other = params[:amount_other]
      if params[:amount_choice] == "other"
        (params[:amount_other].gsub(/[^\d\.]/, '').to_f * 100).to_i
      else
        (params[:amount_choice].to_f * 100).to_i
      end
    end
end
