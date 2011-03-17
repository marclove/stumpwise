class Admin::DashboardController < AdminController
  def index
    @progress_tracker = current_site.progress_tracker
  end
end
