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
    
    # split candidate name and add to user model
    name = site[:name].split(' ')
    @user.first_name, @user.last_name = name[0], name[1..-1].join(' ')

    # copy user.email to the site.campaign_email
    site[:campaign_email] = @user.email
    
    # set the default campaign legal name
    site[:campaign_legal_name] = "#{site[:name]} for #{site[:subhead]}"
    
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
    UserSession.create(@user)
    redirect_to "http://#{@site.subdomain}.#{HOST}/?welcome=true"
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
