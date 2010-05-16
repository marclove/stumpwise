class Manage::SessionsController < ManageController
  layout nil
  skip_before_filter :require_administrator
  
  def new
    @user_session = UserSession.new
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      redirect_back_or_default manage_root_path
    else
      flash.now[:error] = t('user.login.fail')
      render :action => 'new'
    end
  end
  
  def destroy
    current_user_session.destroy if current_user_session
    flash[:notice] = t('user.logout.success')
    redirect_to manage_login_path
  end
end
