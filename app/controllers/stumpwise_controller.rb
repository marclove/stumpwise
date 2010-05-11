class StumpwiseController < ApplicationController
  def show
    if @item = find_item(params[:path])
      send("render_#{@item.class.to_s.underscore}")
    else
      render_404
    end
  end
  
  private
    def find_item(path)
      if path.blank?
        current_site.root_item
      else
        current_site.items.published.find_by_permalink(path.join('/'))
      end
    end
    
    def render_page
      render_liquid_template_for(@item)
    end
    
    def render_blog
      @articles = @item.articles.published.paginate(:page => page, :per_page => per_page)
      render_liquid_template_for(@item, {
        'articles' => @articles.map(&:to_liquid),
        'page' => @articles.current_page,
        'total_pages' => @articles.total_pages,
        'previous_page' => @articles.previous_page,
        'next_page' => @articles.next_page,
        'per_page' => @articles.per_page,
        'path' => request.path
      })
    end
    
    def render_article
      render_liquid_template_for(@item)
    end

    def page
      params[:page] || 1
    end

    def per_page
      params[:per_page] || 5
    end
end
