module Stumpwise
  module Liquid
    module Tags
      
      # {% for item in items %}
      #   {% link_to item %}
      # {% end %}
      #
      # OR
      #
      # {% link_to '/issues/lgbt' %}
      class ItemLink < ::Liquid::Tag
        include ActionView::Helpers
        
        def initialize(name, markup, tokens)
          if match = markup.match(/\s*(#{::Liquid::QuotedString})/)
            @item_path = match[1][1..-2]
          elsif match = markup.match(/\s*(#{::Liquid::QuotedFragment})/) #markup =~ ::Liquid::Expression
            @item_name = match[1]
          else
            # TODO: Explain the proper syntax
            raise SyntaxError.new("Syntax Error in 'link_to'")
          end
          super
        end
        
        def render(context)
          if @item_name
            @item = context[@item_name]
          elsif @item_path
            @item = Item.find_by_permalink(@item_path)
          end
          
          if @item
            @link_text = @link_text.to_s if @link_text
            content_tag(:a, @link_text || @item['title'], :href => @item['permalink'])
          else
            ''
          end
        end
      end
    end
  end
end