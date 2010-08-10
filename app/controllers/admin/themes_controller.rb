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
