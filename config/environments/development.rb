# Copyright (c) 2010-2011 ProgressBound, Inc.
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Stumpwise::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_view.debug_rjs             = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false
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

  HOST = "stumpwise-local.com"

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin
end

