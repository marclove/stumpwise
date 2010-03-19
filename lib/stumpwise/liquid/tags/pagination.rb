module Stumpwise
  module Liquid
    module Tags
      
      class Pagination < ::Liquid::Tag
        include ActionView::Helpers
        
        def initialize(name, markup, tokens)
          super
        end
        
        def render(context)
          if context['page']
            prev_content = link_to_if(context['previous_page'], "&laquo; Previous", prev_link(context), :class => "previous") do
              content_tag :span, "&laquo; Previous", :class => "previous"
            end
            next_content = link_to_if(context['next_page'], "Next &raquo;", next_link(context), :class => "next") do
              content_tag :span, "Next &raquo;", :class => "next"
            end
            content_tag :div, prev_content + ' | ' + next_content, :class => 'pagination'
          else
            ''
          end
        end
        
        def prev_link(context)
          url = "#{context['path']}?page=#{context['previous_page']}"
          url << "&amp;per_page=#{context['per_page']}" if context['per_page']
          url
        end
        
        def next_link(context)
          url = "#{context['path']}?page=#{context['next_page']}"
          url << "&amp;per_page=#{context['per_page']}" if context['per_page']
          url
        end
      end
    end
  end
end