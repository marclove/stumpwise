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
