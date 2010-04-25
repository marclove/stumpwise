class ApplicationController < ActionController::Base
  include Stumpwise::Domains
  include SslRequirement
  before_filter :handle_invalid_site, :set_time_zone, :set_cookie_domain
  
  filter_parameter_logging :password, :token
  
  helper :all
  helper_method :current_user_session, :current_user
  filter_parameter_logging :password, :password_confirmation
  
  protected
    def set_time_zone
      if current_user
        Time.zone = current_user.time_zone
      elsif current_site && current_site != :invalid
        Time.zone = current_site.time_zone
      end
    end

    def handle_invalid_site
      render_404 if current_site == :invalid
    end
    
    # called from the non-administrative controllers instead of ActionController::Base#render
    def render_liquid_template_for(object, assigns = {})
      return render_404 unless object
      headers["Content-Type"] ||= 'text/html; charset=utf-8'
      status = (assigns.delete(:status) || :ok)
      render :status => status, :text => current_site.call_render(object, nil, assigns)
    end
    
    def render_404
      render :file => 'public/404.html', :status => 404
    end
    
    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end
    
    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.record
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
      if require_user && current_site_valid? && !current_site.authorized_user?(current_user)
        flash[:error] = "You are not an authorized user for this site"
        redirect_to :back
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
    
    def store_location
      session[:return_to] = request.request_uri
    end
    
    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end
    
    # Required because Authlogic uses ActionController::Base.session_options
    # instead of rack.session.options. Still not quite sure why they aren't the same.
    def set_cookie_domain
      ActionController::Base.session_options[:domain] = request.env['rack.session.options'][:domain]
    end
end
