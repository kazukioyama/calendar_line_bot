class CalendarController < ApplicationController

  require "google/apis/calendar_v3"
  require "signet/oauth_2/client"
  require "googleauth"
  require "googleauth/stores/file_token_store"

  TOKEN_STORE_FILE = 'credentials.yaml'.freeze
  BASE_URL = "https://9920-14-3-72-98.ngrok.io".freeze
  APPLICATION_NAME = "Google Calendar API Ruby Quickstart".freeze
  GOOGLE_URL = "https://accounts.google.com".freeze
  CLIENT_ID = ENV['CLIENT_ID']
  CLIENT_SECRET = ENV['CLIENT_SECRET']
  SCOPE = 'https://www.googleapis.com/auth/calendar'.freeze

  def auth
    session[:user_id] = params[:user_id]
    client_id = Google::Auth::ClientId.from_file('client_secret.json') # googleauthで使うclient_idは<Google::Auth::ClientId:>クラスにする必要がある
    token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_STORE_FILE)
    authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)

    auth_url = authorizer.get_authorization_url(base_url: BASE_URL)
    redirect_to auth_url # ①認証画面へのリダイレクト(認証コードを取得する用)
  end

  def callback
    code = params[:code] # callbackURIに付与されている認証コードを取得
    user_id = session[:user_id]

    conn = Faraday.new(url: GOOGLE_URL)
    req_body = {
      grant_type: 'authorization_code',
      code: code, # 上で取得した認可コード
      redirect_uri: "https://9920-14-3-72-98.ngrok.io/oauth2callback", # LINEログインのチャネルのコンソールで設定した「コールバックURL」と比較するため
      client_id: CLIENT_ID, # client_secret.json参照
      client_secret: CLIENT_SECRET # client_secret.json参照
    }
    # ②トークン取得用のリクエスト(上で取得した認証コードをパラメータで送信し、トークンを取得)
    res = conn.post do |req|
      req.url '/o/oauth2/token'
      req.body = req_body
    end
    token_data = JSON.parse(res.body) # {"access_token": "〇〇","expires_in": xx, "refresh_token": "△△", "scope": "https://www.googleapis.com/auth/calendar", "token_type": "Bearer"}
    access_token = token_data["access_token"]
    refresh_token = token_data["refresh_token"]
    user = User.find(user_id)
    user.update_attributes!(google_access_token: access_token, google_refresh_token: refresh_token)

    render plain: 'Google連携完了！', status: :ok

    # service = Google::Apis::CalendarV3::CalendarService.new
    # service.client_options.application_name = APPLICATION_NAME

    # # 受け取ったトークンをAPIのclientにブチ込む
    # client = Signet::OAuth2::Client.new(
    #   client_id: CLIENT_ID,
    #   client_secret: CLIENT_SECRET,
    #   access_token: access_token,
    #   refresh_token: refresh_token,
    #   token_credential_uri: 'https://accounts.google.com/o/oauth2/token'
    # )
    # # client.refresh!
    # service.authorization = client

    # calendar_id = "primary"
    # response = service.list_events(calendar_id,
    #                               max_results:   10,
    #                               single_events: true,
    #                               order_by:      "startTime",
    #                               time_min:      DateTime.now.rfc3339)
    # puts "Upcoming events:"
    # puts "No upcoming events found" if response.items.empty?
    # events_list = {summary: []}
    # response.items.each do |event|
    #   start = event.start.date || event.start.date_time
    #   puts "- #{event.summary} (#{start})"
    #   events_list[:summary] << "#{event.summary} (#{start})"
    # end

    # render :json => events_list
  end
end