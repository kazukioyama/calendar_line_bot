module Line::Api
  class Oauth < Base
    include Rails.application.routes.url_helpers

    URL_PATH = 'oauth2/v2.1/authorize'

    def auth_uri(state)
      params = {
        response_type: 'code',
        client_id: @admin.line_login_id,
        redirect_uri: callback_uri,
        state: state,
        scope: 'openid',
        prompt: 'consent',
        bot_prompt: 'aggressive'
      }

      return "#{BASE_URL}/#{URL_PATH}?#{params.to_query}"
    end

    def line_user_id(code)
      varify_id_token(access_token_data(code))['sub']
    end

    private
    def callback_uri
      admin_callback_index_url(@admin.id)
    end

    def access_token_data(code)
      # ① アクセストークン取得用のリクエスト
      req_body = {
        grant_type: 'authorization_code',
        code: code, # 認可後URI(/callback)で付与された認可コード
        redirect_uri: callback_uri, # LINEログインのチャネルのコンソールで設定した「コールバックURL」と比較するため
        client_id: @admin.line_login_id,
        client_secret: @admin.line_login_secret
      }

      puts conn
      res = conn.post do |req|
        req.url '/oauth2/v2.1/token'
        req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
        req.body = req_body
        puts req
      end
      puts res

      return JSON.parse(handle_error(res).body)
    end

    def varify_id_token(access_token_data)
      # ② ユーザID取得用のリクエスト(①で取得したアクセストークンを使用)
      req_body = {
        id_token: access_token_data['id_token'],
        client_id: @admin.line_login_id
      }

      res = conn.post do |req|
        req.url '/oauth2/v2.1/verify'
        req.body = req_body
      end

      return JSON.parse(handle_error(res).body)
    end
  end
end