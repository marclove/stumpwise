module Stumpwise
  module Liquid
    module Tags
      class FacebookWidget < ::Liquid::Tag
        def initialize(name, params, tokens)
          @attributes = {
            'stream' => 'false',
            'connections' => '6',
            'header' => 'true',
            'width' => '220',
            'height' => '290'
          }
          params.scan(::Liquid::TagAttributes) do |var, value|
            @attributes[var] = value
          end
        end
        
        def width
          @attributes['width'] == 'auto' ? "'auto'" : @attributes['width']
        end
        
        def render(context)
          if !context['site.facebook_page_id'].blank? && profile_id = context['site.facebook_page_id']
            profile_attribute = profile_id.integer? ? "id" : "name"
            result = <<-DIV
            <div id=\"facebook_widget\">
              <iframe src="http://www.facebook.com/plugins/likebox.php?#{profile_attribute}=#{profile_id}&amp;width=#{@attributes['width']}&amp;connections=#{@attributes['connections']}&amp;stream=#{@attributes['stream']}&amp;header=#{@attributes['header']}" scrolling="no" frameborder="0" allowTransparency="true" style="border:none; overflow:hidden; width:#{@attributes['width']}px; height:#{@attributes['height']}px;"></iframe>
            </div>
            DIV
          else
            result = ''
          end
          result.html_safe
        end
      end
    end
  end
end