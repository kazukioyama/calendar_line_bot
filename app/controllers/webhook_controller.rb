class WebhookController < ApplicationController
  protect_from_forgery with: :null_session # CSRF許可

  def create
    body = request.body.read #LINE側から送信されたリクエストボディ
    admin = Admin.find(params[:admin_id])
    bot = Line::Api::Bot.new(admin)

    begin
      # 署名の検証（LINEプラットフォームからのリクエストか判定するため）
      unless bot.validate_signature?(body, request.env['HTTP_X_LINE_SIGNATURE'])
        raise Line::InvalidSignatureError
      end
    rescue Line::InvalidSignatureError => e
      render json: { message: 'Invalid signature error' }, status: :unauthorized
    end

    # リクエストボディをパースする
    events = bot.parse_events_from(body)

    line_user_id = events[0]['source']['userId']
    user = User.find_or_create_by!(line_user_id: line_user_id)

    # # 処理中のメッセージを返す
    # Line::SaveSentMessage.new(admin, user).call_with_text(text: "Processing...")

    events.each do |event|
      case event
      when Line::Bot::Event::Message
        Line::SaveReceivedMessage.new(admin, user).call(event) # 受け取ったメッセージをDBに保存
        Line::MessageProcesser.new(admin, user, event).handle_message # 受け取ったメッセージの文字によって別々の処理を行う
      end
    end

    render plain: 'success!', status: :ok
  end
end
