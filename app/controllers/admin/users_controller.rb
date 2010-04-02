class Admin::UsersController < ApplicationController
  before_filter :require_authorized_user
  
=begin
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      self.current_user = @user
      flash[:notice] = t('user.create.success')
      redirect_to admin_user_path(@user)
    else
      flash[:error] = t('user.create.fail')
      render :action => :new
    end
  end
  
  def show
    @user = self.current_user
  end
  
  def edit
    @user = self.current_user
  end
  
  def update
    @user = self.current_user
    if @user.update_attributes(params[:user])
      flash[:notice] = t('user.update.success')
      redirect_to admin_user_path(@user)
    else
      flash[:error] = t('user.update.fail')
      render :action => :edit
    end
  end
=end
end
