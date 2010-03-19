module Stumpwise
  module Liquid
    class LiquidTemplate
      def initialize(site)
        @site = site
      end
      
      def render(template, default_layout = nil, assigns = {}, controller = nil)
        parse_inner_template(template, assigns, controller)
        layout = get_layout(default_layout, assigns)
        parse_template(layout, assigns, controller)
      end
      
      def parse_template(template, assigns, controller)
        tmpl = template.parsed
        returning tmpl.render(assigns, :registers => {:controller => controller, :site => @site}) do |result|
          yield tmpl, result if block_given?
        end
      end
      
      def parse_inner_template(template, assigns, controller)
        parse_template(template, assigns, controller) do |tmpl, result|
          tmpl.assigns.each{ |k,v| assigns[k] = v } if tmpl.respond_to?(:assigns)
          assigns['content_for_layout'] = result
        end
      end
      
      protected
        def get_layout(default_layout = nil, assigns = {})
          # Allows us to override the theme via params for previewing theme
          # before activating it.
          # if assigns['theme']
          #   assigned_theme = @site.available_themes.find_by_name(assigns['theme'])
          # end
          # assigned_theme ||= @site.theme
          
          if assigns['layout']
            #layout = Layout.find_by_filename(assigns['layout'])
            layout = @site.theme.layouts.find_by_filename(assigns['layout'])
          elsif default_layout
            #layout = Layout.find_by_filename(assigns['layout'])
            layout = @site.theme.layouts.find_by_filename(default_layout)
          end
          # If neither layout is provided or found in the database, fallback
          # to layout.tpl which all themes should have.
          return layout || @site.theme.layouts.find_by_filename("layout.tpl")
        end
    end
  end
end