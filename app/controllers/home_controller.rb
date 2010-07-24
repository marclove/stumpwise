class HomeController < ApplicationController
  layout 'marketing'
  ssl_required :signup, :create_site
  filter_parameter_logging :number, :verification_value
  
  def index
    render :action => 'home'
  end
  
  def home
  end
  
  def signup
    @site = Site.new
    @user = User.new
  end
  
  def create_site
    @user = User.new(params[:user])
    site = params[:site]
    @site = Site.new(params[:site])
    
    # unless params[:invite_code] == "pbsw1102"
    #   flash.now[:error] = "I'm sorry, that's not a valid invite code."
    #   render :action => 'signup'
    #   return
    # end

    @customer_result = Braintree::Customer.create(
      :credit_card => params[:credit_card].update(:options => {:verify_card => true})
    )
    
    if @customer_result.success?
      @cc = @customer_result.customer.credit_cards[0]
      # @subscription_result = Braintree::Subscription.create(
      #   :payment_method_token => @cc.token,
      #   :plan_id => "basic"
      # )
    end
    
    if @customer_result.success? # && @subscription_result.success?
      site[:credit_card_token]          = @cc.token
      site[:credit_card_expiration]     = Time.utc(@cc.expiration_year, @cc.expiration_month).end_of_month
      # site[:subscription_id]            = @subscription_result.subscription.id
      # site[:subscription_billing_cycle] = Date.parse(@subscription_result.subscription.first_billing_date).day
      
      User.transaction do
        Site.transaction do
          Administratorship.transaction do
            @user.save!
            @site = @user.owned_sites.build(site)
            @site.save!
            Administratorship.create!(:site => @site, :administrator => @user)
          end
        end
      end
      
      #UserSession.create(@user)
      #redirect_to "http://#{@site.subdomain}.#{HOST}/admin/site/edit"
      redirect_to "http://#{HOST}/thank_you"
    else
      flash.now[:error] = t("site.create.invalid_card")
      render :action => 'signup'
    end
    
  rescue ActiveRecord::RecordInvalid
    flash.now[:error] = t("site.create.fail")
    render :action => 'signup'
  end
  
  def thank_you
  end
end