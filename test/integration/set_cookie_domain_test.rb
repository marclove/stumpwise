require 'test_helper'
 
class SetCookieDomainTest < ActionController::IntegrationTest
 
  context "when accessing site at stumpwise-local.com" do
    setup do
      host! 'stumpwise-local.com'
      visit '/'
    end
 
    should "set cookie_domain to .example.org" do
      assert_equal '.stumpwise-local.com', @integration_session.controller.request.session_options[:domain]
    end
  end
 
  context "when accessing site at site.com" do
    setup do
      host! 'site.com'
      visit '/'
    end
 
    should "set cookie_domain to .site.com" do
      assert_equal '.site.com', @integration_session.controller.request.session_options[:domain]
    end
  end
 
  context "when accessing site at site.stumpwise-local.com" do
    setup do
      host! 'site.stumpwise-local.com'
      visit '/'
    end
 
    should "set cookie_domain to .stumpwise-local.com" do
      assert_equal '.stumpwise-local.com', @integration_session.controller.request.session_options[:domain]
    end
  end
  
  context "when accessing site with an ip address" do
    setup do
      host! '192.168.1.10'
      visit '/'
    end
    
    should "return with a 404" do
      assert_response(404)
    end
  end
end