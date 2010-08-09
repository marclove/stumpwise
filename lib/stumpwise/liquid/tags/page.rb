module Stumpwise
  module Liquid
    module Tags
      class Page < ::Liquid::Block
        def block_delimiter
          "end_#{block_name}"
        end
        
        def render(context)
          if context['displaying'] && context['displaying'] == 'page'
            render_all(@nodelist, context)
          else
            ''
          end
        end
      end
    end
  end
end