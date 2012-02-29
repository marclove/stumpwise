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

class Manage::TemplatesController < ManageController
  before_filter :get_template

  def edit
  end
  
  def update
    if @liquid_template.update_attributes(params[:template] || params[:layout])
      flash[:notice] = 'Template was successfully updated.'
      redirect_to manage_theme_path(@liquid_template.theme)
    else
      render :action => 'new'
    end
  end
  
  def destroy
    @liquid_template.destroy
    redirect_to manage_theme_path(@liquid_template.theme)
  end
  
  private
    def get_template
      @theme = Theme.find(params[:theme_id])
      @liquid_template = @theme.liquid_templates.find(params[:id])
    end
end
