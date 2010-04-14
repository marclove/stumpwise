class Manage::SessionsController < ApplicationController
  layout nil
  skip_before_filter :handle_invalid_site
  
  def new
    @user_session = UserSession.new
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      redirect_to manage_themes_path
    else
      flash[:error] = t('user.login.fail')
      render :action => 'new'
    end
  end
  
  def destroy
    current_user_session.destroy
    flash[:notice] = t('user.logout.success')
    redirect_to manage_login_path
  end
end
