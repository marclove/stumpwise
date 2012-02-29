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

class Manage::ThemesController < ManageController
  def index
    @themes = Theme.all
  end

  def show
    @theme = Theme.find(params[:id])
    @theme_version = @theme.versions.last
  end

  def new
    @theme = Theme.new
    @theme_version = ThemeVersion.new
  end

  def create
    if @theme = Theme.create(params[:theme])
      @theme_version = @theme.versions.create(params[:theme_version])
      
      if params[:theme_assets].present?
        params[:theme_assets].each{|a| @theme_version.theme_assets << ThemeAsset.new(:file => a)}
        @theme_version.save
      end
      
      #extract_vars(params[:theme_variables])
      flash[:notice] = 'Theme was successfully created.'
      redirect_to manage_theme_path(@theme)
    else
      flash[:notice] = 'Theme failed to save.'
      render :action => "new"
    end
  end

  def update
    @theme = Theme.find(params[:id])
    @theme_version = @theme.versions.last
    if @theme.update_attributes(params[:theme]) &&
       @theme_version.update_attributes(params[:theme_version]) &&
       extract_vars(params[:theme_variables])
      
      if params[:theme_assets].present?
        params[:theme_assets].each{|a| @theme_version.theme_assets << ThemeAsset.new(:file => a)}
        @theme_version.save
      end
      
      flash[:notice] = 'Theme was successfully updated.'
      redirect_to manage_theme_path(@theme)
    else
      render :action => "show"
    end
  end
  
  private
    def extract_vars(vars)
      vars.each do |v|
        case v[:type]
        when 'texts'
          @theme_version.texts[v[:name]] = v[:value] if v[:name].present?
        when 'colors'
          @theme_version.colors[v[:name]] = v[:value] if v[:name].present?
        when 'ifs'
          @theme_version.ifs[v[:name]] = (v[:value] == 'true') if v[:name].present?
        when 'images'
          @theme_version.images[v[:name]] = v[:value] if v[:name].present?
        end
      end
      @theme_version.save
    end
end
