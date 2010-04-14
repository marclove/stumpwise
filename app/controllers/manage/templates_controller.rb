class Manage::TemplatesController < ApplicationController
  layout 'manage'
  skip_before_filter :handle_invalid_site
  before_filter :require_administrator, :get_template

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
