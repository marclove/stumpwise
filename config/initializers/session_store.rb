# Be sure to restart your server when you modify this file.

Stumpwise::Application.config.session_store :cookie_store,
  :key => '_stumpwise_session', :domain => :all

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Stumpwise::Application.config.session_store :active_record_store

Stumpwise::Application.config.middleware.insert_before(
  ActionDispatch::Session::CookieStore,
  FlashSessionCookieMiddleware,
  '_stumpwise_session'
)