class HomeController < ApplicationController
  skip_before_filter :handle_invalid_site

  def index
    redirect_to "http://get.stumpwise.com"
  end
end