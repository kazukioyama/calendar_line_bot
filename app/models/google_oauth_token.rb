# frozen_string_literal: true

class GoogleOauthToken < ApplicationRecord
  belongs_to :user

  validates :access_token, presence: true
  validates :refresh_token, presence: true
end