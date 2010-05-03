class InfoController < ApplicationController
  skip_before_filter :handle_invalid_site
  
  def campaigns
    render :file => File.join(Rails.root, 'public', 'agreements', 'campaigns.html'), :layout => 'agreements'
  end

  def conduct
    render :file => File.join(Rails.root, 'public', 'agreements', 'conduct.html'), :layout => 'agreements'
  end

  def privacy
    render :file => File.join(Rails.root, 'public', 'agreements', 'privacy.html'), :layout => 'agreements'
  end

  def supporters
    render :file => File.join(Rails.root, 'public', 'agreements', 'supporters.html'), :layout => 'agreements'
  end
end
