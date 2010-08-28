class ContributionsController < ApplicationController
  layout nil
  before_filter :get_site
  ssl_required :new, :create, :thanks
  filter_parameter_logging :number, :cvv
  
  def new
    @contribution = Contribution.new
    @credit_card = CreditCard.new
  end
  
  def create
    params[:contribution][:amount].gsub!('$','')
    @contribution = @site.contributions.build(params[:contribution])
    @contribution.ip = request.ip
    @credit_card = CreditCard.new(params[:credit_card])

    if @credit_card.valid? && @contribution.save
      @contribution.approve!(:approved, @credit_card.to_hash)
      if @contribution.approved?
        respond_to do |format|
          format.html { redirect_to "/#{@site.subdomain}/contribute/thanks/#{@contribution.order_id}" }
          format.js { render :nothing => true }
        end
      else
        @error = "#{t('contribution.process.fail.rejected')} #{@contribution.transaction_errors}"
        respond_to do |format|
          format.html do
            flash.now[:error] = @error
            render :action => 'new'
          end
          format.js { render :text => @error, :status => :unprocessable_entity }
        end
      end
    else
      @error = t('contribution.process.fail.invalid_record')
      respond_to do |format|
        format.html do
          flash.now[:error] = @error
          render :action => 'new'
        end
        format.js { render :text => @error, :status => :unprocessable_entity }
      end
    end
  end
  
  def thanks
    unless @contribution = @site.contributions.find_by_order_id(params[:order_id])
      raise ActiveRecord::RecordNotFound
    end
  end
  
  private
    def get_site
      unless @site = Site.contributable.find_by_subdomain(params[:subdomain])
        render :file => 'public/404.html', :status => 404
      end
    end
end
