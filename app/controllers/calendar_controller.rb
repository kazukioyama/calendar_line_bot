class CalendarController < ApplicationController

  require "google/apis/calendar_v3"
  require "signet/oauth_2/client"
  require "googleauth"
  require "googleauth/stores/file_token_store"

  SCOPE = 'https://www.googleapis.com/auth/calendar'.freeze
  TOKEN_STORE_FILE = 'credentials.yaml'.freeze
  BASE_URL = "https://9920-14-3-72-98.ngrok.io".freeze
  APPLICATION_NAME = "Google Calendar API Ruby Quickstart".freeze
  GOOGLE_URL = "https://accounts.google.com".freeze
  CLIENT_ID = Google::Auth::ClientId.from_file('client_secret.json')
  CLIENT_SECRET = "TLVmTpg4WAWFIoNp-1A_8LAK".freeze
  # CLIENT_ID = Google::Auth::ClientId.from_file('client_secret.json') # ダウンロードしたファイル

  def auth
    token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_STORE_FILE)
    authorizer = Google::Auth::UserAuthorizer.new(CLIENT_ID, SCOPE, token_store)

    auth_url = authorizer.get_authorization_url(base_url: BASE_URL)
    redirect_to auth_url # ①認証画面へのリダイレクト(認証コードを取得する用)

  end

  def callback
    code = params[:code] # callbackURIに付与されている認証コードを取得

    conn = Faraday.new(url: GOOGLE_URL)
    req_body = {
      grant_type: 'authorization_code',
      code: code, # 上で取得した認可コード
      redirect_uri: "https://9920-14-3-72-98.ngrok.io/oauth2callback", # LINEログインのチャネルのコンソールで設定した「コールバックURL」と比較するため
      client_id: "781888139113-o2m4siifigpv3r38vuudd6lr0uhvqm9o.apps.googleusercontent.com", # client_secret.json参照
      client_secret: "TLVmTpg4WAWFIoNp-1A_8LAK" # client_secret.json参照
    }
    # ②トークン取得用のリクエスト(上で取得した認証コードをパラメータで送信し、トークンを取得)
    res = conn.post do |req|
      req.url '/o/oauth2/token'
      req.body = req_body
    end
    token_data = JSON.parse(res.body) # {"access_token": "〇〇","expires_in": xx, "refresh_token": "△△", "scope": "https://www.googleapis.com/auth/calendar", "token_type": "Bearer"}
    puts "dkld"
    puts token_data
    access_token = token_data["access_token"]
    refresh_token = token_data["refresh_token"]
    puts refresh_token

    service = Google::Apis::CalendarV3::CalendarService.new
    service.client_options.application_name = APPLICATION_NAME

    # 受け取ったトークンをAPIのclientにブチ込む
    client = Signet::OAuth2::Client.new(
      client_id: CLIENT_ID,
      client_secret: CLIENT_SECRET,
      access_token: access_token,
      refresh_token: refresh_token,
      token_credential_uri: 'https://accounts.google.com/o/oauth2/token'
    )
    # client.refresh!
    service.authorization = client

    calendar_id = "primary"
    response = service.list_events(calendar_id,
                                  max_results:   10,
                                  single_events: true,
                                  order_by:      "startTime",
                                  time_min:      DateTime.now.rfc3339)
    puts "Upcoming events:"
    puts "No upcoming events found" if response.items.empty?
    events_list = {summary: []}
    response.items.each do |event|
      start = event.start.date || event.start.date_time
      puts "- #{event.summary} (#{start})"
      events_list[:summary] << "#{event.summary} (#{start})"
    end

    render :json => events_list
  end
end

# https://tagamidaiki.com/ruby-google-drive-api-accesstoken/