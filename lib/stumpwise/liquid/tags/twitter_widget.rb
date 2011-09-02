module Stumpwise
  module Liquid
    module Tags
      class TwitterWidget < ::Liquid::Tag
        def initialize(name, params, tokens)
          @attributes = {
            'tweets'      => '5',
            'avatars'     => 'true',
            'timestamps'  => 'true',
            'hashtags'    => 'true',
            'loop'        => 'false',
            'live'        => 'false',
            'interval'    => '6000',
            'shell_bg'    => '"#002266"',
            'shell_text'  => '"#FFFFFF"',
            'tweet_bg'    => '"#001122"',
            'tweet_text'  => '"#FFFFFF"',
            'links'       => '"#6699FF"',
            'width'       => 'auto',
            'height'      => '300'
          }
          params.scan(::Liquid::TagAttributes) do |var, value|
            @attributes[var] = value
          end
        end
        
        def width
          @attributes['width'] == 'auto' ? '"\'auto\'"' : @attributes['width']
        end
        
        def render(context)
          if !context['site.twitter_username'].blank? && username = context['site.twitter_username']
            result = <<-DIV
            <div id=\"twitter_widget\">
            <script src=\"http://widgets.twimg.com/j/2/widget.js\"></script>
            <script>
              new TWTR.Widget({
                version: 2,
                type: 'profile',
                rpp: #{context[@attributes['tweets']]},
                interval: #{context[@attributes['interval']]},
                width: #{context[width]},
                height: #{context[@attributes['height']]},
                theme: {
                  shell: {
                    background: '#{context[@attributes['shell_bg']]}',
                    color: '#{context[@attributes['shell_text']]}'
                  },
                  tweets: {
                    background: '#{context[@attributes['tweet_bg']]}',
                    color: '#{context[@attributes['tweet_text']]}',
                    links: '#{context[@attributes['links']]}'
                  }
                },
                features: {
                  scrollbar: false,
                  loop: #{context[@attributes['loop']]},
                  live: #{context[@attributes['live']]},
                  hashtags: #{context[@attributes['hashtags']]},
                  timestamp: #{context[@attributes['timestamps']]},
                  avatars: #{context[@attributes['avatars']]},
                  behavior: 'all'
                }
              }).render().setUser('#{username}').start();
            </script>
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