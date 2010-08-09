module Stumpwise
  module Liquid
    module Tags
      class Blog < ::Liquid::Block
        def block_delimiter
          "end_#{block_name}"
        end
        
        def render(context)
          if context['displaying'] && context['displaying'] == 'blog'
            render_all(@nodelist, context)
          else
            ''
          end
        end
      end
    end
  end
end