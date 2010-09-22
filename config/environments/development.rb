# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

#config.after_initialize {
#  ActiveSupport::Dependencies.load_once_paths.delete(File.join(Rails.root, 'lib'))
#}

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = true
config.action_mailer.perform_deliveries = true
config.action_mailer.default_charset = "utf-8"
config.action_mailer.delivery_method = :smtp 
config.action_mailer.smtp_settings = {
  :address => "smtp.sendgrid.net",
  :port => 587,
  :domain => "stumpwise.com",
  :authentication => :plain,
  :user_name => "marc@stumpwise.com",
  :password => "ioQkyaaavKb1njYX6KEJ",
  :enable_starttls_auto => true
}

config.after_initialize do
  Braintree::Configuration.environment = :sandbox
  Braintree::Configuration.merchant_id = "8jw8y63nqbd3qxyy"
  Braintree::Configuration.public_key  = "nvpczrn9gxhy4h3w"
  Braintree::Configuration.private_key = "sy9ymwccmnp5whmd"
  Twilio.connect('AC290b369fef9ffa8920ca99314daa329d', '3754013e10389ded382a62d5f2830b43')
end

SslRequirement.disable_ssl_check = true
HOST = "stumpwise-local.com"

config.middleware.use "SetCookieDomain", ".stumpwise-local.com"