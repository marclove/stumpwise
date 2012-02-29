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

class Manage::SitesController < ManageController
  before_filter :get_site, :except => [:index, :new, :create]

  def index
    @sites = Site.all(:order => "created_at DESC")
  end
  
  def new
    @site = Site.new
    @user = User.new
  end
  
  def create
    @site = Site.new(params[:site])
    @user = User.new(params[:user])
    
    User.transaction do
      Site.transaction do
        @user_saved = @user.save
        @site = @user.owned_sites.build(params[:site])
        @site_saved = @site.save
        @administratorship_created = Administratorship.create(:site => @site, :administrator => @user)
      end
    end
    
    if @user_saved && @site_saved && @administratorship_created
      @site.update_attribute(:active, params[:site][:active])
      @site.update_attribute(:can_accept_contributions, params[:site][:can_accept_contributions])
      @site.set_theme!(Theme.first.id.to_s)
      redirect_to manage_sites_path
    else
      flash.now[:error] = t("site.create.fail")
      render :action => 'new'
    end
  end
  
  def edit
  end
  
  def update
    if @site.update_attributes(params[:site])
      @site.update_attribute(:active, params[:site][:active])
      @site.update_attribute(:can_accept_contributions, params[:site][:can_accept_contributions])
      flash[:notice] = t("site.update.success")
      redirect_to manage_sites_path
    else
      flash.now[:error] = t("site.update.fail")
      render :action => 'edit'
    end
  end
  
  def destroy
    if @site.destroy
      flash[:notice] = t("site.destroy.success")
      redirect_to manage_sites_path
    else
      flash[:error] = t("site.destroy.fail")
      redirect_to :back
    end
  end
  
  private
    def get_site
      @site = Site.find(params[:id], :include => :owner)
    end
end
