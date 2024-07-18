class User < ApplicationRecord
  has_one :google_oauth_token
end
