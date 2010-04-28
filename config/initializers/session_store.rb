# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_stumpwise_session',
  :secret      => '2e4414297a40a663f6f7c31e9848238de502deece0f3c5dc339d1e56f15c9d0f43e68b250acda090da95b4f7efbfe5a9f02a3eb757316439c5c9d7f1f5248625'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store

ActionController::Dispatcher.middleware.insert_before(
  ActionController::Session::CookieStore, 
  FlashSessionCookieMiddleware, 
  ActionController::Base.session_options[:key]
)