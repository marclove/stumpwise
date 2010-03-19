require 'test_helper'
require 'liquid'

module Test
  module Unit
    module Assertions
        include Liquid
        def assert_template_result(expected, template, assigns={}, message=nil)
          assert_equal expected, Template.parse(template).render(assigns)
        end 
    end
  end
end

class LiquidTagsTest < ActionView::TestCase
  include Liquid
  
  context "Custom tags" do
    setup do 
      @context = Context.new()
      @item = Page.make(:title => 'News', :slug => 'news')
    end
    
    should "link to an item by passing its liquid object" do
      assert_template_result '<a href="/news">News</a>', "{% link_to item %}", {'item' => @item.to_liquid}
    end
    
    should "link to an item by passing its permalink" do
      assert_template_result '<a href="/news">News</a>', "{% link_to '/news' %}", {'site' => @item.site.to_liquid}
    end
    
    should "render a Twitter widget" do
      default_result = <<-RESULT
            <div id=\"twitter_widget\">
            <script src=\"http://widgets.twimg.com/j/2/widget.js\"></script>
            <script>
              new TWTR.Widget({
                version: 2,
                type: 'profile',
                rpp: 5,
                interval: 6000,
                width: 'auto',
                height: 300,
                theme: {
                  shell: {
                    background: '#333333',
                    color: '#FFFFFF'
                  },
                  tweets: {
                    background: '#000000',
                    color: '#FFFFFF',
                    links: '#4AED05'
                  }
                },
                features: {
                  scrollbar: false,
                  loop: false,
                  live: false,
                  hashtags: true,
                  timestamp: true,
                  avatars: true,
                  behavior: 'all'
                }
              }).render().setUser('marcslove').start();
            </script>
            </div>
            RESULT

      custom_result = <<-CUSTOM_RESULT
            <div id=\"twitter_widget\">
            <script src=\"http://widgets.twimg.com/j/2/widget.js\"></script>
            <script>
              new TWTR.Widget({
                version: 2,
                type: 'profile',
                rpp: 10,
                interval: 3000,
                width: 400,
                height: 700,
                theme: {
                  shell: {
                    background: '#444444',
                    color: '#CCCCCC'
                  },
                  tweets: {
                    background: '#111111',
                    color: '#DDDDDD',
                    links: '#AAAAAA'
                  }
                },
                features: {
                  scrollbar: false,
                  loop: true,
                  live: true,
                  hashtags: false,
                  timestamp: false,
                  avatars: false,
                  behavior: 'all'
                }
              }).render().setUser('marcslove').start();
            </script>
            </div>
            CUSTOM_RESULT
      assert_template_result(default_result, "{% twitter %}", {'site' => {'twitter_username' => 'marcslove'}})
      assert_template_result(custom_result, "{% twitter tweets:10, avatars:false, timestamps:false, hashtags:false, loop:true, live:true, interval:3000, shell_bg:#444444, shell_text:#CCCCCC, tweet_bg:#111111, tweet_text:#DDDDDD, links:#AAAAAA, width:400, height:700 %}", {'site' => {'twitter_username' => 'marcslove'}})
    end
  end
end
