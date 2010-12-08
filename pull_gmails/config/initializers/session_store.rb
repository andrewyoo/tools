# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_pull_gmails_session',
  :secret      => '93e986fa3023409e12cd2cddbfab65472e3ad4cb9c11a208c53543fb9facdf371a5c54a9108696123cd7d011457cebe799bb430332c649c5020b95377b610c71'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
