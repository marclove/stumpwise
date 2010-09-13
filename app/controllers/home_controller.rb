class HomeController < ApplicationController
  layout 'marketing'
  ssl_required :signup, :create_site
  filter_parameter_logging :number, :cvv
  
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
    site = params[:site].merge(:active => true)
    @site = Site.new(params[:site])
    
    @customer_result = Braintree::Customer.create(
      :credit_card => params[:credit_card].update(:options => {:verify_card => true})
    )
    
    if @customer_result.success?
      @cc = @customer_result.customer.credit_cards[0]
      site[:credit_card_token]          = @cc.token
      site[:credit_card_expiration]     = Time.utc(@cc.expiration_year, @cc.expiration_month).end_of_month
      
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
      @site.set_theme!(Theme.first.id.to_s)
      UserSession.create(@user)
      redirect_to "http://#{@site.subdomain}.#{HOST}/admin/site/edit"
    else
      flash.now[:error] = t("site.create.invalid_card")
      render :action => 'signup'
    end
    
  rescue ActiveRecord::RecordInvalid => e
    notify_hoptoad(e)
    flash.now[:error] = t("site.create.fail")
    render :action => 'signup'
  end
  
  # Can't use robots.txt because it will interfere w/campaign sites' auto-generated robots.txt files
  def robots
    render :file => File.join(Rails.root, 'public', '_robots.txt'), :layout => false
  end
  
  # Can't use sitemap.xml because it will interfere w/campaign sites' auto-generated sitemap.xml files
  def sitemap
    render :layout => false
  end
end
