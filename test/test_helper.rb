ENV["RAILS_ENV"] = "test"
I_KNOW_I_AM_USING_AN_OLD_AND_BUGGY_VERSION_OF_LIBXML2 = "leave me alone"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'
require 'shoulda'
require 'matchy'
require 'blueprints'
require 'fakeweb'
require 'webrat'
require 'authlogic/test_case'

Webrat.configure do |config|
  config.mode = :rails
end

class ActiveSupport::TestCase
  include ActiveMerchant::Billing

  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually 
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all
  
  setup { Sham.reset }

  def compact_html(str)
    str.squish!.gsub(/> </, '><')
  end
  
  def assert_html_equal(html1,html2)
    assert_equal compact_html(html1), compact_html(html2)
  end
  
  def assert_blank(attribute)
    assert attribute.blank?, "#{attribute} was expected to be blank"
  end
  
  def assert_not_blank(attribute)
    assert !attribute.blank?, "#{attribute} should have had a value, but was blank"
  end
  
  def make_site_with_pages
    Site.make do |site|
      3.times { site.pages.make }
    end
  end
  
  def address(options = {})
    { :name     => 'Marc Love',
      :address1 => '2400 Market Street',
      :address2 => 'Suite 1000',
      :city     => 'San Francisco', 
      :state    => 'CA',
      :country  => 'US',
      :zip      => '94114'
    }.update(options)
  end
  
  def credit_card_hash(options = {})
    { :number     => '1',
      :first_name => 'Marc',
      :last_name  => 'Love',
      :month      => '1',
      :year       => "#{ Time.now.year + 1 }",
      :verification_value => '123',
      :type       => 'visa' 
    }.update(options)
  end

  def credit_card(options = {})
    ActiveMerchant::Billing::CreditCard.new(credit_card_hash(options))
  end
  
  def setup_session_domain
    @request.env['rack.session.options'] = {:domain => ".localdev.com"}
  end
  
  def login_as(fixture_name)
    setup_session_domain
    activate_authlogic
    UserSession.create(users(fixture_name))
  end
  
  def on_site(fixture_name)
    @controller.stubs(:current_site).returns(sites(fixture_name))
  end
end