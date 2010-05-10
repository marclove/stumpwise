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
      @item = Page.make(:title => 'News', :slug => 'news', :body => "test")
    end
    
    should "link to an item by passing its liquid object" do
      assert_template_result '<a href="/news">News</a>', "{% link_to item %}", {'item' => @item.to_liquid}
    end
    
    should "link to an item by passing its permalink" do
      assert_template_result '<a href="/news">News</a>', "{% link_to 'news' %}", {'site' => @item.site.to_liquid}
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
                    background: '#002266',
                    color: '#FFFFFF'
                  },
                  tweets: {
                    background: '#001122',
                    color: '#FFFFFF',
                    links: '#6699FF'
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
      assert_template_result(default_result, "{% twitter_widget %}", {'site' => {'twitter_username' => 'marcslove'}})
      assert_template_result(custom_result, "{% twitter_widget tweets:10, avatars:false, timestamps:false, hashtags:false, loop:true, live:true, interval:3000, shell_bg:#444444, shell_text:#CCCCCC, tweet_bg:#111111, tweet_text:#DDDDDD, links:#AAAAAA, width:400, height:700 %}", {'site' => {'twitter_username' => 'marcslove'}})
    end
    
    should "render a Facebook widget" do
      default_result = <<-DEFAULT_RESULT
            <div id=\"facebook_widget\">
              <iframe src="http://www.facebook.com/plugins/likebox.php?id=1234567890&amp;width=220&amp;connections=6&amp;stream=false&amp;header=true" scrolling="no" frameborder="0" allowTransparency="true" style="border:none; overflow:hidden; width:220px; height:290px;"></iframe>
            </div>
      DEFAULT_RESULT
      
      custom_result = <<-CUSTOM_RESULT
            <div id=\"facebook_widget\">
              <iframe src="http://www.facebook.com/plugins/likebox.php?name=Anthony.Woods&amp;width=400&amp;connections=20&amp;stream=true&amp;header=false" scrolling="no" frameborder="0" allowTransparency="true" style="border:none; overflow:hidden; width:400px; height:500px;"></iframe>
            </div>
      CUSTOM_RESULT
      
      assert_template_result(default_result, "{% facebook_widget %}", {'site' => {'facebook_page_id' => '1234567890'}})
      assert_template_result(custom_result, "{% facebook_widget stream:true connections:20 header:false width:400 height:500 %}", {'site' => {'facebook_page_id' => 'Anthony.Woods'}})
    end
  end
end
