ActionController::Routing::Routes.draw do |map|
  map.with_options(:conditions => {:subdomain => false, :domain => BASE_URL}) do |base|
    base.root :controller => 'home', :action => 'index'
  end
  
  map.with_options(:conditions => {:subdomain => 'contribute', :domain => BASE_URL}) do |c|
    # https://contribute.stumpwise.com/woods
    c.connect ':subdomain', :controller => 'contributions', :action => 'new'
    # https://contribute.stumpwise.com/woods/process
    # https://contribute.stumpwise.com/woods/thanks/r94473624dj5d78fkfvmvht36
    #c.connect ':subdomain/:action/:order_id', :controller => 'contributions'
  end

  map.namespace(:admin) do |admin|
    admin.resources :sessions, :only => [:new, :create, :destroy]
    admin.login  'login',  :controller => 'sessions', :action => 'new'
    admin.logout 'logout', :controller => 'sessions', :action => 'destroy'
    #admin.resources :users

    admin.resource  :site

    admin.resources :assets
    admin.resources :pages, :member => { :publish => :put, :unpublish => :put }
    admin.resources :articles, :member => { :publish => :put, :unpublish => :put }
    admin.resources :blogs do |b|
      b.resources :articles, :member => { :publish => :put, :unpublish => :put }
    end
    
    #admin.resources :layouts
    #admin.resources :templates
    #admin.resources :stylesheets
    #admin.resources :javascripts
    
    admin.resources :supporters, :only => [:index, :show, :destroy], :collection => {:export => :get}
    admin.resources :contributions, :only => [:index, :show]
    
    admin.root :controller => 'blogs', :action => 'index'
  end
  
  map.resources :assets,        :only => [:show]
  map.resources :stylesheets,   :only => [:show]
  map.resources :javascripts,   :only => [:show]
  map.resources :supporters,    :only => [:new, :create]
  map.join 'join', :controller => 'supporters', :action => 'new'
  map.connect '*path', :controller => 'stumpwise', :action => 'show'
end
