class ContributionsController < ApplicationController
  layout nil
  before_filter :get_site
  ssl_required :new, :create, :thanks
  filter_parameter_logging :number, :verification_value
  
  def new
    @contribution = Contribution.new
    @credit_card = CreditCard.new
  end
  
  def create
    @contribution = @site.contributions.build(params[:contribution])
    @contribution.ip = request.ip
    @credit_card = CreditCard.new(params[:credit_card])
    @amount_choice, @amount_other = params[:amount_choice], params[:amount_other]
    @contribution.amount = (@amount_choice == 'other' ? @amount_other : @amount_choice)

    if @credit_card.valid? && @contribution.save
      @contribution.approve!(:approved, @credit_card.to_hash)
      if @contribution.approved?
        redirect_to "/#{@site.subdomain}/contribute/thanks/#{@contribution.order_id}"
      else
        flash.now[:error] = "#{t('contribution.process.fail.rejected')} #{@contribution.transaction_errors}"
        render :action => 'new'
      end
    else
      flash.now[:error] = t('contribution.process.fail.invalid_record')
      render :action => 'new'
    end
  end
  
  def thanks
    unless @contribution = @site.contributions.find_by_order_id(params[:order_id])
      raise ActiveRecord::RecordNotFound
    end
  end
  
  private
    def get_site
      unless @site = Site.find_by_subdomain(params[:subdomain])
        render :file => 'public/404.html', :status => 404
      end
    end
end
