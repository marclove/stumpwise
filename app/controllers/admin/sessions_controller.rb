class Admin::SessionsController < AdminController
  layout nil
  skip_before_filter :require_authorized_user, :require_acceptance_of_campaign_agreement
  
  def new
    @user_session = UserSession.new
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      redirect_back_or_default admin_dashboard_path
    else
      flash.now[:error] = t('user.login.fail')
      render :action => 'new'
    end
  end
  
  def destroy
    current_user_session.destroy if current_user_session
    flash[:notice] = t('user.logout.success')
    redirect_to admin_login_path
  end
end
