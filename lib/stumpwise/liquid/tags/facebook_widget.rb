module Stumpwise
  module Liquid
    module Tags
      class FacebookWidget < ::Liquid::Tag
        def initialize(name, params, tokens)
          @attributes = {
            'stream' => '0',
            'connections' => '6',
            'logobar' => '1',
            'width' => '220',
            'height' => '251'
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
            result = <<-DIV
            <div id=\"facebook_widget\">
    					<script type="text/javascript" src="http://static.ak.connect.facebook.com/js/api_lib/v0.4/FeatureLoader.js.php/en_US"></script>
    					<script type="text/javascript">FB.init("a9d92ba216c544f61a752bf756df9a10");</script>
    					<fb:fan profile_id="#{profile_id}" stream="#{@attributes['stream']}" connections="#{@attributes['connections']}" logobar="#{@attributes['logobar']}" width="#{@attributes['width']}" height="#{@attributes['height']}"></fb:fan>
            </div>
            DIV
          else
            result = ''
          end
          result
        end
      end
    end
  end
end