Stumpwise::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Specifies the header that your server uses for sending files
  config.action_dispatch.x_sendfile_header = "X-Sendfile"

  # For nginx:
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

  # If you have no front-end server that supports something like X-Sendfile,
  # just comment this out and Rails will serve the files

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Disable Rails's static asset server
  # In production, Apache or nginx will already do this
  config.serve_static_assets = false

  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify
  
  config.action_mailer.default_charset = "utf-8"
  config.action_mailer.smtp_settings = {
    :address => "smtp.sendgrid.net",
    :port => '25',
    :domain => "stumpwise.com",
    :authentication => :plain,
    :user_name => "marc@stumpwise.com",
    :password => "ioQkyaaavKb1njYX6KEJ"
  }

  config.after_initialize do
    Braintree::Configuration.environment = :production
    Braintree::Configuration.merchant_id = "mvmy94yfkzp3zkq5"
    Braintree::Configuration.public_key  = "3dcrfwkk5trng5fr"
    Braintree::Configuration.private_key = "t75vk6k4qjcvvtpc"
    Twilio.connect('AC290b369fef9ffa8920ca99314daa329d', '3754013e10389ded382a62d5f2830b43')
  end

  HOST = "stumpwise.com"

  Delayed::Worker.destroy_failed_jobs = false
end
