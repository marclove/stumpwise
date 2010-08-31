# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

# Because the new ActiveSupport chokes ActiveMerchant
require 'active_support/all'

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )
  %w(middleware uploaders drops observers mailers jobs).each do |dir|
    config.load_paths << "#{RAILS_ROOT}/app/#{dir}"
  end

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"
  config.gem 'RedCloth'
  config.gem 'liquid', :version => '2.1.2'
  config.gem 'bcrypt-ruby', :lib => 'bcrypt', :version => '2.1.2'
  config.gem 'authlogic'
  config.gem 'delayed_job'
  config.gem 'will_paginate', :version => '2.3.12'
  config.gem 'carrierwave'
  config.gem 'braintree', :version => '2.2.0'
  config.gem 'shenie-ssl_requirement', :lib => 'ssl_requirement'
  config.gem 'twilio', :version => '2.8.0'
  config.gem 'newrelic_rpm'
  config.gem 'hoptoad_notifier'
  config.gem 'aasm'
  config.gem 'jnunemaker-validatable', :lib => 'validatable', :version => '>=1.8.4'
  config.gem 'geokit'
  config.gem 'mongo_mapper', :version => '0.8.3'
  config.gem 'joint', :version => '0.3.2'
  
  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]
  
  config.middleware.use "Navbar"
  
  require 'app/middleware/gridfs'
  mongo = YAML.load_file(Rails.root.join('config', 'mongo.yml'))[Rails.env]
  config.middleware.use "Rack::GridFS", 
    :hostname => mongo['host'], :port => mongo['port'],
    :username => mongo['username'], :password => mongo['password'],
    :database => mongo['database'], :prefix => 'gridfs'
  
  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  config.active_record.observers = :supportership_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'Pacific Time (US & Canada)'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
end

SubdomainFu.tld_size = 1 # all environments
SubdomainFu.preferred_mirror = "www"