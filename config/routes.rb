Stumpwise::Application.routes.draw do

  constraints(:subdomain => /^(www)?$/i, :domain => HOST) do
    match 'info/:action', :controller => :info, :via => :get
    match 'home' => 'home#home', :via => :get
    match 'robots.txt' => 'home#robots', :via => :get
    match 'sitemap.xml' => 'home#sitemap', :via => :get
    root :to => 'home#index'
  end

  constraints(:subdomain => 'admin', :domain => HOST) do
    namespace :manage do
        resources :sites
        resources :contributions do
        member do
          put :refund
        end
      end
      resources :users
      resources :themes do
        resources :layouts
        resources :templates
        resources :theme_assets
      end
      resources :sessions
      match 'login' => 'sessions#new', :as => :login
      match 'logout' => 'sessions#destroy', :as => :logout
      root :to => 'sites#index'
    end
  end

  constraints(:subdomain => 'secure', :domain => HOST, :protocol => 'https://') do
    # https://secure.stumpwise.com/woods/contribute
    match ':site_subdomain/contribute' => 'contributions#new', :via => :get
    # https://secure.stumpwise.com/woods/contribute
    match ':site_subdomain/contribute' => 'contributions#create', :via => :post
    # https://secure.stumpwise.com/woods/contribute/thanks/r94473624dj5d78fkfvmvht36
    match ':site_subdomain/contribute/thanks/:order_id' => 'contributions#thanks', :via => :get
    match 'signup' => 'home#signup', :via => :get
    match 'create_site' => 'home#create_site', :via => :post
  end

  namespace :admin do
    match 'terms' => 'info#terms', :as => :terms
    match 'accept_terms' => 'info#accept_terms', :as => :accept_terms

    resources :sessions, :only => [:new, :create, :destroy]
    match 'login' => 'sessions#new', :as => :login
    match 'logout' => 'sessions#destroy', :as => :logout
    resource :profile

    resource :site
    resource :navigation
    resource :theme do
      member do
        put :set_theme
        put :reset_customization
      end
    end

    resources :assets
    resources :pages do
      member do
        put :unpublish
        put :publish
      end
    end

    resources :blogs do
      resources :articles do
        member do
          put :unpublish
          put :publish
        end
      end
    end

    resources :supporters, :only => [:index, :show, :destroy] do
      collection do
        get :export
      end
    end

    resources :contributions, :only => [:index, :show] do
      collection do
        get :summary
        get :export
        get :settings
        put :update_settings
      end
      member do
        put :refund
      end
    end
    resources :sms_campaigns
    root :to => 'dashboard#index'
  end

  resources :supporters, :only => [:new, :create]
  match 'join' => 'supporters#new', :as => :join

  match '(*path)' => 'stumpwise#show'
end
