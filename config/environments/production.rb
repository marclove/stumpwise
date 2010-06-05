# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true

# See everything in the log (default is :info)
# config.log_level = :debug

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Use a different cache store in production
# config.cache_store = :mem_cache_store

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false

# Enable threaded mode
# config.threadsafe!

config.action_mailer.default_charset = "utf-8"
config.action_mailer.smtp_settings = {
  :address => "smtp.sendgrid.net",
  :port => '25',
  :domain => "stumpwise.com",
  :authentication => :plain,
  :user_name => "marc.love@progressbound.com",
  :password => "ioQkyaaavKb1njYX6KEJ"
}

config.after_initialize do
  ActiveMerchant::Billing::Base.mode = :production
  ContributionTransaction.gateway =
    ActiveMerchant::Billing::Base.gateway('braintree').new(
      :merchant_id => "mvmy94yfkzp3zkq5",
      :public_key  => "3dcrfwkk5trng5fr",
      :private_key => "t75vk6k4qjcvvtpc"
    )
end

BASE_URL = "stumpwise.com"
HOST = "stumpwise.com"

config.middleware.use "SetCookieDomain", ".stumpwise.com"