class ThemeController < ApplicationController
  layout nil
  
  def stylesheets
    if stylesheet = current_site.stylesheets.find_by_filename("#{params[:filename]}.#{params[:ext]}")
      if stale?(:etag => stylesheet, :last_modified => stylesheet.updated_at.utc, :public => true)
        response.content_type = "text/css"
        render :text => stylesheet.content
      end
    else
      head(:not_found)
    end
  end
  
  def javascripts
    if javascript = current_site.javascripts.find_by_filename("#{params[:filename]}.#{params[:ext]}")
      if stale?(:etag => javascript, :last_modified => javascript.updated_at.utc, :public => true)
        response.content_type = "text/javascript"
        render :text => javascript.content
      end
    else
      head(:not_found)
    end
  end
end
