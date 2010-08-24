class StumpwiseController < ApplicationController
  before_filter :handle_invalid_site, :reject_inactive_site
  
  def show
    if @item = find_item(params[:path])
      send("render_#{@item.class.to_s.underscore}")
    else
      render_404
    end
  end
  
  private
    def set_navbar_headers
      request.env[:navbar] = Stumpwise::Navbar.new(current_site)
    end
    
    def find_item(path)
      if path.blank?
        current_site.root_item
      else
        current_site.items.published.find_by_permalink(path.join('/'))
      end
    end
    
    def render_page
      render_liquid(@item)
    end
    
    def render_blog
      @articles = @item.articles.paginate(
        :conditions => {:published => true}, 
        :page => params[:page], 
        :per_page => params[:per_page]
      )
      render_liquid(@item, {
        'articles' => @articles.map(&:to_liquid),
        'current_page' => @articles.current_page,
        'total_pages' => @articles.total_pages,
        'previous_page' => @articles.previous_page,
        'next_page' => @articles.next_page,
        'per_page' => @articles.per_page,
        'path' => request.path
      })
    end
    
    def render_article
      render_liquid(@item, {'blog' => true})
    end
    
    def render_liquid(object, assigns = {})
      set_navbar_headers
      @tpl, theme_assigns = current_site.template
      assigns.update('site' => current_site.to_liquid, object.liquid_name => object.to_liquid, 'theme' => theme_assigns)
      result = @tpl.render(assigns, :registers => {:controller => self, :site => current_site})
      render :text => result, :status => :ok, :content_type => 'text/html;charset=utf-8'
    end
end
