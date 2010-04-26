require 'test_helper'
 
class SetCookieDomainTest < ActionController::IntegrationTest
 
  context "when accessing site at localdev.com" do
    setup do
      host! 'localdev.com'
      visit '/'
    end
 
    should "set cookie_domain to .example.org" do
      assert_equal '.localdev.com', @integration_session.controller.request.session_options[:domain]
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
 
  context "when accessing site at site.localdev.com" do
    setup do
      host! 'site.localdev.com'
      visit '/'
    end
 
    should "set cookie_domain to .localdev.com" do
      assert_equal '.localdev.com', @integration_session.controller.request.session_options[:domain]
    end
  end
 
end