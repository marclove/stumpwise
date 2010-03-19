class HomeController < ApplicationController
  skip_before_filter :handle_invalid_site

  def index
    render :text => "Welcome to Stumpwise!"
  end
end