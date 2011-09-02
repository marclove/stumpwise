require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module Stumpwise
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    %w(middleware uploaders drops observers mailers jobs).each do |dir|
      config.autoload_paths << "#{Rails.root}/app/#{dir}"
    end
    config.autoload_paths << File.join(config.root, "lib")
    config.eager_load_paths << File.join(config.root, "lib")

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named
    config.plugins = [ :all ]

    config.middleware.use "Navbar"

    require Rails.root.join('app','middleware','gridfs')
    mongo = YAML.load_file(Rails.root.join('config', 'mongo.yml'))[Rails.env]
    config.middleware.use "Rack::GridFS", 
      :hostname => mongo['host'], :port => mongo['port'],
      :username => mongo['username'], :password => mongo['password'],
      :database => mongo['database'], :prefix => 'gridfs'

    # Skip frameworks you're not going to use. To use Rails without a database,
    # you must remove the Active Record framework.
    # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

    # Activate observers that should always be running
    config.active_record.observers = :supportership_observer, :progress_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names.
    config.time_zone = 'Pacific Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
    # config.i18n.default_locale = :de

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]
  end
end