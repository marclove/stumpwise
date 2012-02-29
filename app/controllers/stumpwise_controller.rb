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

class StumpwiseController < ApplicationController
  before_filter :handle_invalid_site, :reject_inactive_site
  layout nil
  
  def show
    find_item(params[:path])

    case @item
    when :sitemap
      render :action => :sitemap
    when :robots
      render :text => "Sitemap: #{current_site.root_url}/sitemap.xml"
    when :in_development
      render :file => 'public/indevelopment.html', :status => 404
    when :not_found, nil
      render_404
    else
      send("render_#{@item.class.to_s.underscore}")
    end
  end
  
  def sitemap
    last_item = current_site.items.last
    if stale?(:etag => last_item, :last_modified => last_item.updated_at.utc)
      @items = current_site.items
    end
  end
  
  private
    def set_navbar_headers
      request.env[:navbar] = Stumpwise::Navbar.new(current_site, current_user.present?, self)
    end
    
    def find_item(path)
      @path = path || ''
      if @path.end_with?("/feed")
        @is_feed = true
        @path = @path.gsub(/\/feed$/,'')
      end
      
      if @path.blank?
        unless @item = current_site.root_item
          @item = :in_development
        end
      elsif @path == "sitemap.xml"
        @item = :sitemap
      elsif @path == "robots.txt"
        @item = :robots
      else
        unless @item = current_site.items.published.find_by_permalink(path)
          @item = :not_found
        end
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
      if @is_feed
        render :template => 'stumpwise/show.atom.builder'
      else
        previous_page = @articles.current_page > 1 && @articles.current_page - 1
        next_page = @articles.current_page < @articles.total_pages && @articles.current_page + 1
        render_liquid(@item, {
          'articles' => @articles.map(&:to_liquid),
          'current_page' => @articles.current_page,
          'total_pages' => @articles.total_pages,
          'previous_page' => previous_page,
          'next_page' => next_page,
          'per_page' => @articles.per_page,
          'path' => request.path
        })
      end
    end
    
    def render_article
      render_liquid(@item, {'blog' => @item.blog})
    end
    
    def render_liquid(object, assigns = {})
      set_navbar_headers
      @tpl, theme_assigns = current_site.template
      assigns.update('site' => current_site.to_liquid, object.liquid_name => object.to_liquid, 'theme' => theme_assigns)
      result = @tpl.render(assigns, :registers => {:controller => self, :site => current_site})
      render :text => result, :status => :ok, :content_type => 'text/html;charset=utf-8'
    end
end
