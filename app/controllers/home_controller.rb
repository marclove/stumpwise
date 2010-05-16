class HomeController < ApplicationController
  def index
    redirect_to "http://get.stumpwise.com"
  end
end