require 'test_helper'
require 'liquid'

class SiteDropTest < Test::Unit::TestCase
  include Liquid
  
  context "Site Drop" do
    setup do
      attributes = {
        :name => 'Woods For Congress', 
        :subhead => 'The Courage of Conviction', 
        :keywords => 'Democrat, 10th Congressional District, Iraq War Vet', 
        :description => 'Anthony Woods, Iraqi War Vet, running for California\'s 10th Congressional District', 
        :disclaimer => 'Paid for by the Committee To Elect Anthony Woods', 
        :subdomain => 'woods',
        :public_email => 'info@woodsforcongress.com', 
        :public_phone => '(510) 555-5555', 
        :twitter_username => 'woods4congress', 
        :facebook_page_id => '123456789',
        :flickr_username => 'anthonywoods', 
        :youtube_username => 'anthonywoods', 
        :google_analytics_id  => 'UA-99999-1'
      }
      @site = Site.new(attributes).to_liquid
      @site_custom_domain = Site.new(attributes.merge(:custom_domain => "woodsforcongress.com")).to_liquid
    end
    
    should "have name attribute" do
      assert_equal 'Woods For Congress', @site['name']
    end
    
    should "have subhead attribute" do
      assert_equal "The Courage of Conviction", @site['subhead']
    end
    
    should "have keywords attribute" do
      assert_equal "Democrat, 10th Congressional District, Iraq War Vet", @site['keywords']
    end
    
    should "have description attribute" do
      assert_equal "Anthony Woods, Iraqi War Vet, running for California's 10th Congressional District", @site['description']
    end
    
    should "have disclaimer attribute" do
      assert_equal "Paid for by the Committee To Elect Anthony Woods", @site['disclaimer']
    end
    
    should "have root_url attribute" do
      assert_equal "http://woods.localdev.com", @site['root_url']
      assert_equal "http://woodsforcongress.com", @site_custom_domain['root_url']
    end
    
    should "have public_email attribute" do
      assert_equal "info@woodsforcongress.com", @site['public_email']
    end
    
    should "have public_phone attribute" do
      assert_equal "(510) 555-5555", @site['public_phone']
    end
    
    should "have a twitter username attribute" do
      assert_equal "woods4congress", @site['twitter_username']
    end
    
    should "have a facebook page id attribute" do
      assert_equal "123456789", @site['facebook_page_id']
    end
    
    should "have a flickr username attribute" do
      assert_equal "anthonywoods", @site['flickr_username']
    end
    
    should "have a youtube username attribute" do
      assert_equal "anthonywoods", @site['youtube_username']
    end
    
    should "have a google analytics id attribute" do
      assert_equal "UA-99999-1", @site['google_analytics_id']
    end
  end
end