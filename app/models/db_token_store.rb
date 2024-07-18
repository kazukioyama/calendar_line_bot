# frozen_string_literal: true

class DbTokenStore
  def load(id)
    token = GoogleOauthToken.find_by(user_id: id)
    return nil if token.nil?

    JSON.dump({
                access_token: token.access_token,
                refresh_token: token.refresh_token
              })
  end

  def store(id, token)
    token_hash = JSON.parse(token)
    token = GoogleOauthToken.find_or_initialize_by(user_id: id)
    token.update!(
      access_token: token_hash['access_token'],
      refresh_token: token_hash['refresh_token']
    )
  end

  def delete(id)
    token = GoogleOauthToken.find_by(user_id: id)
    token&.destroy!
  end
end
