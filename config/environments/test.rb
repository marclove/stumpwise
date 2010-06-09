# Settings specified here will take precedence over those in config/environment.rb

# The test environment is used exclusively to run your application's
# test suite.  You never need to work with it otherwise.  Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs.  Don't rely on the data there!
config.cache_classes = true

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false
config.action_view.cache_template_loading            = true

# Disable request forgery protection in test environment
config.action_controller.allow_forgery_protection    = false

# Tell Action Mailer not to deliver emails to the real world.
# The :test delivery method accumulates sent emails in the
# ActionMailer::Base.deliveries array.
config.action_mailer.delivery_method = :test

# Use SQL instead of Active Record's schema dumper when creating the test database.
# This is necessary if your schema can't be completely dumped by the schema dumper,
# like if you have constraints or database-specific column types
# config.active_record.schema_format = :sql

SslRequirement.disable_ssl_check = true
BASE_URL = "localdev.com"
HOST = "localdev.com:3000"

config.middleware.use "SetCookieDomain", ".localdev.com"

config.gem 'machinist'
config.gem 'shoulda', '2.10.3'
config.gem 'factory_girl'
config.gem 'webrat'
config.gem "fakeweb"

config.after_initialize do
  Braintree::Configuration.environment = :sandbox
  Braintree::Configuration.merchant_id = "8jw8y63nqbd3qxyy"
  Braintree::Configuration.public_key  = "nvpczrn9gxhy4h3w"
  Braintree::Configuration.private_key = "sy9ymwccmnp5whmd"
end

require 'fakeweb'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
FakeWeb.allow_net_connect = false

# Twitter
FakeWeb.register_uri(:post, 'http://twitter.com/oauth/request_token', :body => 'oauth_token=fake&oauth_token_secret=fake')
FakeWeb.register_uri(:post, 'http://twitter.com/oauth/access_token', :body => 'oauth_token=fake&oauth_token_secret=fake')
FakeWeb.register_uri(:get, 'http://twitter.com/account/verify_credentials.json', :response => File.join(RAILS_ROOT, 'features', 'fixtures', 'verify_credentials.json'))
