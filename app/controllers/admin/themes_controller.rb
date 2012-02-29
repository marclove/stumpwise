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

class Admin::ThemesController < AdminController
  def show
    #@themes = Theme.all({:listed => true, :order => 'created_at asc'})
    @themes = Theme.all({:order => 'created_at asc'})
  end
  
  def set_theme
    if current_site.set_theme!(params[:id])
      respond_to do |f|
        f.html { redirect_to :action => :show }
        f.js do
          render :partial => 'theme_customization', :object => current_site.theme_customization, :layout => false
        end
      end
    else
      respond_to do |f|
        f.html do
          flash[:error] = t("theme.change.fail")
          redirect_to :action => :show
        end
        f.js do
          render :text => t("theme.change.fail"),
                 :status => :unprocessable_entity
        end
      end
    end
  end
  
  def update
    @theme_customization = current_site.theme_customization
    
    if @theme_customization && @theme_customization.update_attributes(params[:theme_customization])
      if images = params[:theme_customization_images]
        images.each do |name, file|
          @theme_customization.theme_images << ThemeImage.new(:name => name, :file => file)
        end
        @theme_customization.save
      end
      
      respond_to do |f|
        f.html { redirect_to :action => 'show' }
        f.js { render :nothing => true }
      end
    else
      respond_to do |f|
        f.html do
          flash.now[:error] = t("theme_customization.update.fail")
          redirect_to :action => 'show'
        end
        f.js do 
          render :text => t("theme_customization.update.fail"),
                  :status => :unprocessable_entity
        end
      end
    end
  end
  
  def reset_customization
    if has_customization
      @theme_customization.reset!
    end
    redirect_to :action => :show
  end
  
  private
    def has_customization
      @theme_customization = current_site.theme_customization
    end
end
