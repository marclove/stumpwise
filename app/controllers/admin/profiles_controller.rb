class Admin::ProfilesController < AdminController
  def edit
    @user = self.current_user
  end
  
  def update
    @user = self.current_user
    if @user.update_attributes(params[:user])
      flash[:notice] = t('profile.update.success')
      redirect_to edit_admin_profile_path
    else
      flash.now[:error] = t('profile.update.fail')
      render :action => :edit
    end
  end
end
