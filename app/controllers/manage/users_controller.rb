class Manage::UsersController < ApplicationController
  layout 'manage'
  skip_before_filter :handle_invalid_site
  before_filter :require_administrator
  before_filter :get_user, :only => [:edit, :update, :destroy]

  def index
    @page = params[:page] || 1
    @users = User.paginate(
      :per_page => 10,
      :page => @page,
      :order => "created_at DESC"
    )
  end
  
  def search
    params[:conditions].assert_valid_keys(:first_name, :last_name, :email)
    @users = User.paginate(
      :per_page => params[:per_page].to_i || 10,
      :page => params[:page].to_i || 1,
      :order => 'created_at DESC',
      :conditions => params[:conditions]
    )
  rescue ArgumentError
    flash[:error] = t('user.invalid_search')
    redirect_to :back
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = t('user.create.success')
      redirect_to manage_user_path(@user)
    else
      flash[:error] = t('user.create.fail')
      render :action => 'new'
    end
  end
  
  def edit
  end
  
  def update
    if @user.update_attributes(params[:user])
      flash[:notice] = t('user.update.success')
      redirect_to manage_users_path
    else
      flash[:error] = t('user.update.fail')
      render :action => 'edit'
    end
  end
  
  def destroy
    @user.destroy
  end
  
  private
    def get_user
      @user = User.find(params[:id])
    end
end
