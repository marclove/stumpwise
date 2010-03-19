class StumpwiseController < ApplicationController
  def show
    if params[:path].empty?
      @item = current_site.root_item
    else
      @item = current_site.items.first(:conditions => {
        :permalink => params[:path].join('/'),
        :published => true
      })
    end

    if @item.is_a?(Blog)
      @articles = @item.articles.paginate(:conditions => {:published => true}, :page => page, :per_page => per_page)
      render_liquid_template_for(@item, {
        'articles' => @articles.map(&:to_liquid),
        'page' => page,
        'total_pages' => @articles.total_pages,
        'previous_page' => @articles.previous_page,
        'next_page' => @articles.next_page,
        'per_page' => per_page,
        'path' => request.path
      })
    else
      render_liquid_template_for(@item)
    end
  end
  
  private
    def page
      params[:page] || 1
    end
    
    def per_page
      params[:per_page] || 5
    end
end
