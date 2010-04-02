class ContributionsController < ApplicationController
  layout nil
  skip_before_filter :handle_invalid_site
  before_filter :get_site
  ssl_required :new, :create, :thanks
  filter_parameter_logging :card_number, :verification_value
  
  
  def new
    @contribution = Contribution.new
  end
  
  def create
    @contribution = @site.contributions.build(params[:contribution])
    if @contribution.credit_card.valid?
      @contribution.ip = request.ip
      @contribution.amount = contribution_amount
      if @contribution.save
        response = @contribution.process
        if response.success?
          flash.now[:notice] = t('contribution.process.success')
          redirect_to url_for(:subdomain => @site.subdomain, :controller => 'contributions', :action => 'thanks', :order_id => @contribution.order_id, :only_path => true, :secure => true)
        else
          flash.now[:error] = "#{t('contribution.process.fail.rejected')} #{response.message}"
          render :action => 'new'
        end
      else
        puts @contribution.save
        flash.now[:error] = t('contribution.process.fail.invalid_record')
        # the contribution record was invalid, error messages will be embedded in the form
        render :action => 'new'
      end
    else
      flash.now[:error] = t('contribution.process.fail.invalid_record')
      flash.now[:card_error] = t('contribution.process.fail.invalid_card')
      render :action => 'new'
    end
  end
  
  def thanks
    @contribution = Contribution.find_by_order_id(params[:order_id])
  end
  
  private
    def get_site
      @site = Site.find_by_subdomain(params[:subdomain])
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
