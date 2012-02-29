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

require 'test_helper'

class SiteDropTest < ActiveSupport::TestCase
  context "Site Drop" do
    setup do
      @attrs = {
        :name => 'Woods For Congress', 
        :subhead => 'The Courage of Conviction', 
        :keywords => 'Democrat, 10th Congressional District, Iraq War Vet', 
        :description => 'Anthony Woods, Iraqi War Vet, running for California\'s 10th Congressional District', 
        :disclaimer => 'Paid for by the Committee To Elect Anthony Woods', 
        :subdomain => 'woods',
        :campaign_email => 'info@woodsforcongress.com', 
        :campaign_phone => '(510) 555-5555', 
        :twitter_username => 'woods4congress', 
        :facebook_page_id => '123456789',
        :flickr_username => 'anthonywoods', 
        :youtube_username => 'anthonywoods', 
        :campaign_legal_name => 'Anthony Woods For Congress',
        :campaign_street => '123 Anywhere Street',
        :campaign_city => 'San Francisco',
        :campaign_state => 'CA',
        :campaign_zip => '95111'
      }
      site = Site.new(@attrs)
      site.can_accept_contributions = true
      @site_drop = Factory(:site).to_liquid
    end
    
    should "have name attribute" do
      assert_equal 'Woods For Congress', @site_drop['name']
    end
    
    should "have subhead attribute" do
      assert_equal "The Courage of Conviction", @site_drop['subhead']
    end
    
    should "have keywords attribute" do
      assert_equal "Democrat, 10th Congressional District, Iraq War Vet", @site_drop['keywords']
    end
    
    should "have description attribute" do
      assert_equal "Anthony Woods, Iraqi War Vet, running for California's 10th Congressional District", @site_drop['description']
    end
    
    should "have disclaimer attribute" do
      assert_equal "Paid for by the Committee To Elect Anthony Woods", @site_drop['disclaimer']
    end
    
    should "have campaign_email attribute" do
      assert_equal "info@woodsforcongress.com", @site_drop['campaign_email']
    end
    
    should "have campaign_phone attribute" do
      assert_equal "(510) 555-5555", @site_drop['campaign_phone']
    end
    
    should "have a twitter username attribute" do
      assert_equal "woods4congress", @site_drop['twitter_username']
    end
    
    should "have a facebook page id attribute" do
      assert_equal "123456789", @site_drop['facebook_page_id']
    end
    
    should "have a flickr username attribute" do
      assert_equal "anthonywoods", @site_drop['flickr_username']
    end
    
    should "have a youtube username attribute" do
      assert_equal "anthonywoods", @site_drop['youtube_username']
    end
    
    should "have a contribute url" do
      assert_equal "https://secure.stumpwise-local.com/tonywoods/contribute", @site_drop['contribute_url']
    end
    
    should "return true for accepts_contributions?" do
      assert @site_drop['accepts_contributions?']
    end
    
    should "have a campaign legal name" do
      assert_equal "Anthony Woods For Congress", @site_drop['campaign_legal_name']
    end
    
    should "have a campaign street address" do
      assert_equal "123 Anywhere Street", @site_drop['campaign_street']
    end
    
    should "have a campaign city" do
      assert_equal "San Francisco", @site_drop['campaign_city']
    end
    
    should "have a campaign state" do
      assert_equal "CA", @site_drop['campaign_state']
    end
    
    should "have a campaign zip code" do
      assert_equal "95111", @site_drop['campaign_zip']
    end
    
    should "have a copyright" do
      assert_equal "Copyright &copy; #{Time.now.year} Anthony Woods For Congress", @site_drop['copyright']
    end
    
    should "have a candidate photo url" do
      site_drop = sites(:with_candidate_photo).to_liquid
      assert_equal "http://stumpwise-test.s3.amazonaws.com/sites/7/candidate/image_t1.jpg", site_drop['candidate_photo']
    end
    
    # TODO: Better test
    should "return the site's root navigation items as an array of items" do
      site_drop = sites(:woods).to_liquid
      assert_equal items(:root_1).to_liquid, site_drop['navigation'][0]
      assert_equal items(:root_2).to_liquid, site_drop['navigation'][1]
      assert_equal items(:root_3).to_liquid, site_drop['navigation'][2]
    end
    
    context "for site without custom domain" do
      should "have root_url that uses the subdomain" do
        assert_equal "http://tonywoods.stumpwise-local.com", @site_drop['root_url']
      end
      
      context "and with Google Analytics ID" do
        setup do
          @site_drop = Factory(:site_with_analytics).to_liquid
        end
        
        should "have a google analytics id attribute" do
          assert_equal "UA-99999-1", @site_drop['google_analytics_id']
        end

        should "return embed code for Google Analytics without site-specific code" do
          result = <<-CODE
          <script type="text/javascript">
            var _gaq = _gaq || [];
            _gaq.push(['_setAccount', 'UA-15839704-1']);
            _gaq.push(['_setDomainName', 'none']);
            _gaq.push(['_setAllowLinker', true])
            _gaq.push(['_trackPageview']);
            (function() {
              var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
              ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
              var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
            })();
          </script>
          CODE
          assert_html_equal result, @site_drop['google_analytics_code']
        end
      end
    end
    
    context "for site with custom domain" do
      setup do
        @site_drop = Factory(:site_with_custom_domain).to_liquid
      end
      
      should "have root_url that uses the custom domain" do
        assert_equal "http://anthonywoods1.com", @site_drop['root_url']
      end
      
      should "return embed code for Google Analytics without site-specific code" do
        result = <<-CODE
        <script type="text/javascript">
          var _gaq = _gaq || [];
          _gaq.push(['_setAccount', 'UA-15839704-1']);
          _gaq.push(['_setDomainName', 'none']);
          _gaq.push(['_setAllowLinker', true])
          _gaq.push(['_trackPageview']);
          (function() {
            var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
            ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
            var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
          })();
        </script>
        CODE
        assert_html_equal result, @site_drop['google_analytics_code']
      end
      
      context "and with Google Analytics ID set" do
        setup do
          @site_drop = Factory(:site_with_custom_domain_and_analytics).to_liquid
        end
        
        should "have a Google Analytics ID attribute" do
          assert_equal "UA-99999-1", @site_drop['google_analytics_id']
        end

        should "return embed code for Google Analytics with site-specific code" do
          result = <<-CODE
          <script type="text/javascript">
            var _gaq = _gaq || [];
            _gaq.push(['_setAccount', 'UA-15839704-1']);
            _gaq.push(['_setDomainName', 'none']);
            _gaq.push(['_setAllowLinker', true])
            _gaq.push(['_trackPageview']);
            if ('tonywoods4.stumpwise.com' != document.location.hostname) {
              _gaq.push(['b._setAccount', 'UA-99999-1']);
              _gaq.push(['b._setDomainName', '.anthonywoods2.com']);
              _gaq.push(['b._trackPageview']);
            }
            (function() {
              var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
              ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
              var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
            })();
          </script>
          CODE
          assert_html_equal result, @site_drop['google_analytics_code']
        end
      end
    end
    
    context "for site that can't accept contributions" do
      setup do
        @site_drop = sites(:cannot_accept_contributions).to_liquid
      end
      
      should "return nothing for contribute_url" do
        assert_equal nil, @site_drop['contribute_url']
      end
      
      should "return false for accepts_contributions?" do
        assert !@site_drop['accepts_contributions?']
      end
    end
  end
end