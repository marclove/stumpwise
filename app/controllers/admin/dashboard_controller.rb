class Admin::DashboardController < ApplicationController
  def index
    @progress_tracker = current_site.progress_tracker
  end
end
