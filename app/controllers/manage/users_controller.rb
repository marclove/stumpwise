# Copyright (c) 2010-2011 ProgressBound, Inc.
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class Manage::UsersController < ManageController
  before_filter :get_user, :only => [:edit, :update, :destroy]

  def index
    @page = params[:page] || "1"
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
      flash.now[:error] = t('user.create.fail')
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
      flash.now[:error] = t('user.update.fail')
      render :action => 'edit'
    end
  end
  
  def destroy
    if @user.destroy
      flash[:notice] = t("user.destroy.success")
      redirect_to manage_users_path
    else
      flash[:error] = t("user.destroy.fail")
      redirect_to :back
    end
  end
  
  private
    def get_user
      @user = User.find(params[:id])
    end
end
