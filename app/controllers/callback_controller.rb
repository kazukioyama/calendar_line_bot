class CallbackController < ApplicationController
  # /admin/:admin_id/callback?code=〇〇&state=〇〇&friendship_status_changed=〇
  ## params[:code] → 後に行うアクセストークン取得に使用するための認可コード
  ## params[:state] → CSRF対策用に認可URLに付与しておいた値
  def index
    admin = Admin.find(params[:admin_id])
    puts(params[:state] == session[:state])

    raise Line::InvalidState if params[:state] != session[:state]

    line_user_id = Line::Api::Oauth.new(admin).line_user_id(params[:code]) # アクセストークン取得→ユーザID取得 (リクエスト2回実行される)
    User.create!(line_user_id: line_user_id) # line_user_idカラムに値の有無で、userがLINEログインしているかどうかを判別できるため

    render plain: 'LINE連携完了！', status: :ok
  end
end
