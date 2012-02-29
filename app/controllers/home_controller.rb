# Copyright (c) 2010-2011 ProgressBound, Inc.
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class HomeController < ApplicationController
  layout 'marketing'
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
