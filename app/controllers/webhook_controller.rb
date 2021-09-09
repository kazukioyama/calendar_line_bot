class WebhookController < ApplicationController
  protect_from_forgery with: :null_session # CSRF許可

  def create
    admin = Admin.find(params[:admin_id]) #LINEコンソール側で設定したWebhookURLから

    bot = Line::Api::Bot.new(admin)
    body = request.body.read #LINE側から送信されたリクエストボディ

    #署名の検証(LINEプラットフォームからのリクエストか判定するため)
    raise Line::InvalidSignatureError unless bot.validate_signature?(body, request.env['HTTP_X_LINE_SIGNATURE'])

    events = bot.parse_events_from(body)
    events.each do |event|
      case event
      when Line::Bot::Event::Message
        Line::SaveReceivedMessage.new(admin).call(event)
        Line::SaveSentMessage.new(admin).call_with_text(line_user_id: event['source']['userId'], text: "response")
        Line::SaveSentMessage.new(admin).call_with_text(line_user_id: event['source']['userId'], text: "https://9920-14-3-72-98.ngrok.io/google/auth")
        # case event.type
        # when Line::Bot::Event::MessageType::Text

        # end
      end
    end

    render plain: 'success!', status: :ok
  end
end
