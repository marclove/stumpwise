module Stumpwise
  module Liquid
    module Tags
      
      class Pagination < ::Liquid::Tag
        include ActionView::Helpers
        attr_accessor :output_buffer
        
        def initialize(name, markup, tokens)
          super
        end
        
        def render(context)
          if context['current_page']
            prev_content = link_to_if(context['previous_page'], "&laquo; Previous".html_safe, prev_link(context), :class => "prev_page") do
              content_tag :span, "&laquo; Previous".html_safe, :class => "prev_page disabled"
            end
            next_content = link_to_if(context['next_page'], "Next &raquo;".html_safe, next_link(context), :class => "next_page") do
              content_tag :span, "Next &raquo;".html_safe, :class => "next_page disabled"
            end
            content_tag :div, prev_content + next_content, :class => 'pagination'
          else
            ''
          end
        end
        
        def prev_link(context)
          url = "#{context['path']}?page=#{context['previous_page']}".html_safe
          url << "&amp;per_page=#{context['per_page']}".html_safe if context['per_page']
          url
        end
        
        def next_link(context)
          url = "#{context['path']}?page=#{context['next_page']}".html_safe
          url << "&amp;per_page=#{context['per_page']}".html_safe if context['per_page']
          url
        end
      end
    end
  end
end