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
  :port => '587',
  :domain => "stumpwise.com",
  :authentication => :plain,
  :user_name => "marc.love@progressbound.com",
  :password => "ioQkyaaavKb1njYX6KEJ"
}

config.after_initialize do
  ActiveMerchant::Billing::Base.mode = :production
  ContributionTransaction.gateway =
    ActiveMerchant::Billing::Base.gateway('paypal').new(
      :login => 'billing_api1.progressbound.com',
      :password => 'S3Z8JT73P5UA8H2F',
      :signature => 'AFcWxV21C7fd0v3bYYYRCpSSRl31AtqRsGGkj3Mi7JF9RjKunsb07YR-'
    )
end

BASE_URL = "stumpwise.com"
HOST = "stumpwise.com"

config.middleware.use "SetCookieDomain", ".stumpwise.com"