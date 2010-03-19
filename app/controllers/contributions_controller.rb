class ContributionsController < ApplicationController
  layout nil
  skip_before_filter :handle_invalid_site
  before_filter :get_site
  ssl_required :new, :create, :thanks
  
  def new
  end
  
  def create
    @contribution = @site.build_contribution(params[:contribution])
    if @contribution.credit_card.valid?
      @contribution.ip = request.ip
      if @contribution.save
        response = @contribution.process
        if response.success?
          flash[:notice] = t('contribution.process.success')
          redirect_to url_for(:controller => 'contributions', :action => 'thanks', :order_id => @contribution.order_id, :only_path => true, :secure => true)
        else
          flash[:error] = "#{t('contribution.process.fail.rejected')} #{response.message}"
          render :action => 'new'
        end
      else
        # the contribution record was invalid, error messages will be embedded in the form
        render :action => 'new'
      end
    else
      flash[:error] = t('contribution.process.fail.invalid_card')
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
end
