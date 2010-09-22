ActionController::Routing::Routes.draw do |map|
  map.with_options(:conditions => {:subdomain => false, :domain => HOST}) do |base|
    base.connect 'info/:action', :controller => 'info', :conditions => {:method => :get}
    base.connect 'home', :controller => 'home', :action => 'home'
    base.connect 'robots.txt', :controller => 'home', :action => 'robots'
    base.connect 'sitemap.xml', :controller => 'home', :action => 'sitemap'
    base.root :controller => 'home', :action => 'index'
  end
  
  map.with_options(:conditions => {:subdomain => 'admin', :domain => HOST}) do |a|
    a.namespace(:manage) do |manage|
      manage.resources :sites
      manage.resources :contributions, :only => [:index, :show], :member => {:refund => :put}
      manage.resources :users
      manage.resources :themes do |t|
        t.resources :layouts
        t.resources :templates
        t.resources :theme_assets, :as => :assets, :name_prefix => 'manage_'
      end
    
      manage.resources :sessions, :only => [:create]
      manage.login  'login',  :controller => 'sessions', :action => 'new'
      manage.logout 'logout', :controller => 'sessions', :action => 'destroy'
    
      manage.root :controller => 'sites', :action => 'index'
    end
  end
  
  map.with_options(:conditions => {:subdomain => 'secure', :domain => HOST}) do |c|
    # https://secure.stumpwise.com/woods/contribute
    c.connect ':subdomain/contribute', :controller => 'contributions', :action => 'new', :conditions => {:method => :get}
    # https://secure.stumpwise.com/woods/contribute
    c.connect ':subdomain/contribute', :controller => 'contributions', :action => 'create', :conditions => {:method => :post}
    # https://secure.stumpwise.com/woods/contribute/thanks/r94473624dj5d78fkfvmvht36
    c.connect ':subdomain/contribute/:action/:order_id', :controller => 'contributions'
    
    c.connect 'signup', :controller => 'home', :action => 'signup'
    c.connect 'create_site', :controller => 'home', :action => 'create_site'
  end

  map.namespace(:admin) do |admin|
    admin.terms 'terms', :controller => 'info', :action => 'terms'
    admin.accept_terms 'accept_terms', :controller => 'info', :action => 'accept_terms'
    admin.welcome 'welcome', :controller => 'info', :action => 'welcome'
    
    admin.resources :sessions, :only => [:new, :create, :destroy]
    admin.login  'login',  :controller => 'sessions', :action => 'new'
    admin.logout 'logout', :controller => 'sessions', :action => 'destroy'
    admin.resource :profile

    admin.resource :site
    admin.resource :navigation
    admin.resource :theme, :member => { :set_theme => :put, :reset_customization => :put }

    admin.resources :assets
    admin.resources :pages, :member => { :publish => :put, :unpublish => :put }
    #admin.resources :articles, :member => { :publish => :put, :unpublish => :put }
    admin.resources :blogs do |b|
      b.resources :articles, :member => { :publish => :put, :unpublish => :put }
    end
        
    admin.resources :supporters, :only => [:index, :show, :destroy], :collection => {:export => :get}
    admin.resources :contributions, :only => [:index, :show], :collection => {:summary => :get, :export => :get, :settings => :get, :update_settings => :put}, :member => {:refund => :put}
    admin.resources :sms_campaigns
    admin.root :controller => 'blogs', :action => 'index'
  end
  
  map.resources :supporters, :only => [:new, :create]
  map.join 'join', :controller => 'supporters', :action => 'new'
  map.connect '*path', :controller => 'stumpwise', :action => 'show'
end
