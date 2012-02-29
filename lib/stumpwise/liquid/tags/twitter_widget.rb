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