class GoogleOauthController < ApplicationController
  def auth
    client_id = Rails.application.credentials.google[:oauth_client_id]
    client_secret = Rails.application.credentials.google[:oauth_client_secret]

    auth_client_id = Google::Auth::ClientId.new(client_id, client_secret)
    token_store = DbTokenStore.new
    authorizer = Google::Auth::UserAuthorizer.new(
      auth_client_id,
      [
        'https://www.googleapis.com/auth/calendar'
      ],
      token_store,
      callback_google_oauth_index_url
    )
    user_id = params[:user_id].to_i
    session[:user_id] = user_id
    credentials = authorizer.get_credentials(user_id) # アクセストークン等の資格情報の取得（認可済かどうか）
    if credentials.nil?
      auth_url = authorizer.get_authorization_url(request: request)
      redirect_to auth_url
    else
      render plain: '既に認証済みです', status: :ok
    end
  end

  def callback
    code = params[:code] # callbackURIに付与されている認可コードを取得
    user_id = session[:user_id]

    # アクセストークン取得用のリクエスト(上で取得した認可コードをパラメータで送信し、トークンを取得)
    conn = Faraday.new(url: 'https://accounts.google.com')
    req_body = {
      grant_type: 'authorization_code',
      code: code,
      redirect_uri: callback_google_oauth_index_url,
      client_id: Rails.application.credentials.google[:oauth_client_id],
      client_secret: Rails.application.credentials.google[:oauth_client_secret]
    }
    res = conn.post do |req|
      req.url '/o/oauth2/token'
      req.body = req_body
    end

    token_data = JSON.parse(res.body) # {"access_token": "〇〇","expires_in": xx, "refresh_token": "△△", "scope": "https://www.googleapis.com/auth/calendar", "token_type": "Bearer"}
    access_token = token_data['access_token']
    refresh_token = token_data['refresh_token']
    GoogleOauthToken.create!(user_id: user_id, access_token: access_token, refresh_token: refresh_token)

    render plain: "Google連携完了！\nLINEチャットからメッセージを送ることで、Googleカレンダーの情報を取得できます。", status: :ok
  end
end
