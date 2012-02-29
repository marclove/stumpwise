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

class ApplicationController < ActionController::Base
  include Stumpwise::Domains
  before_filter :set_time_zone, :set_current_user
  
  filter_parameter_logging :password, :token
  
  helper :all
  helper_method :current_user_session, :current_user, :super_admin?
  filter_parameter_logging :password, :password_confirmation
  
  protected
    def set_time_zone
      if current_user
        Time.zone = current_user.time_zone
      elsif current_site
        Time.zone = current_site.time_zone
      end
    end

    def handle_invalid_site
      render_404 unless current_site
    end
    
    def reject_inactive_site
      render_404 if !current_site.active?
    end
    
    def render_404
      render :file => 'public/404.html', :status => 404
      return
    end
    
    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end
    
    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.record
    end
    
    def set_current_user
      Thread.current['user'] = current_user
    end
    
    def super_admin?
      current_user && current_user.super_admin?
    end
    
    def require_user
      unless current_user
        store_location
        flash[:error] = "You must be logged in to access this page"
        redirect_to admin_login_url
        return false
      end
      true
    end
    
    def require_authorized_user
      if require_user && current_site && !current_site.authorized_user?(current_user)
        flash[:error] = "You are not an authorized user for this site"
        redirect_to admin_login_url
        return false
      end
    end
    
    def require_administrator
      unless current_user && current_user.super_admin?
        store_location
        flash[:error] = "You must be logged in to access this page."
        redirect_to manage_login_url
        return false
      end
      true
    end
    
    def require_no_user
      if current_user
        store_location
        flash[:notice] = "You must be logged out to access this page"
        redirect_to account_url
        return false
      end
    end
    
    def require_acceptance_of_campaign_agreement
      unless current_user.accepted_campaign_terms?
        store_location
        redirect_to admin_terms_path
        return false
      end
      return true
    end
    
    def store_location
      session[:return_to] = request.request_uri
    end
    
    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end
end
