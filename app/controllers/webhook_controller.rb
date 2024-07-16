class WebhookController < ApplicationController
  protect_from_forgery with: :null_session # CSRF許可

  def create
    body = request.body.read #LINE側から送信されたリクエストボディ

    begin
      admin = Admin.find(params[:admin_id])
      bot = Line::Api::Bot.new(admin)
      # 署名の検証（LINEプラットフォームからのリクエストか判定するため）
      unless bot.validate_signature?(body, request.env['HTTP_X_LINE_SIGNATURE'])
        raise Line::InvalidSignatureError
      end

    rescue ActiveRecord::RecordNotFound => e
      render json: { message: "Admin not found: #{e.message}" }, status: :not_found
    rescue Line::InvalidSignatureError => e
      render json: { message: 'Invalid signature error' }, status: :unauthorized
    rescue => e
      puts "An Error occurred!!!"
      puts e
      Line::SaveSentMessage.new(admin).call_with_text(
        line_user_id: line_user_id,
        text: "Sorry, an error occurred on the server."
      )
    end

    events = bot.parse_events_from(body)
    events.each do |event|
      case event
      when Line::Bot::Event::Message
        line_user_id = event['source']['userId']
        puts "line_user_id"
        puts line_user_id
        Line::SaveReceivedMessage.new(admin).call(event)
        Line::SaveSentMessage.new(admin).call_with_text(line_user_id: line_user_id, text: "Processing...")
        begin
          user = User.find_by(line_user_id: line_user_id)
          # user_id = user.id
        rescue NoMethodError => e
          Line::SaveSentMessage.new(admin).call_with_text(
            line_user_id: line_user_id,
            text: "LINEユーザIDが見つかりません。ログインしてください。"
          )
        end
        if user&.google_access_token&.nil?
          Line::SaveSentMessage.new(admin).call_with_text(
            line_user_id: line_user_id,
            text: "Please click the following URL to authenticate your Google account.\n\n#{auth_url(user)}"
          )
        else
          begin
            case event["message"]["text"]
            when "Get Upcoming Event"
              events_list = Calendar::GoogleCalendar.new(user).get_events(1)
              events_list[:summary].each do |value|
                Line::SaveSentMessage.new(admin).call_with_text(line_user_id: line_user_id, text: value)
              end
            when "Get 10 Events"
              events_list = Calendar::GoogleCalendar.new(user).get_events(10)
              events_list[:summary].each do |value|
                Line::SaveSentMessage.new(admin).call_with_text(line_user_id: line_user_id, text: value)
              end
            when "Switch Between Google Accounts"
              Line::SaveSentMessage.new(admin).call_with_text(line_user_id: line_user_id, text: "Please click the following URL to authenticate your Google account.\n\n#{auth_url(user)}")
            when "Hello"
              Line::SaveSentMessage.new(admin).call_with_text(line_user_id: line_user_id, text: "Hi! Thank you for using me.")
              Line::SaveSentMessage.new(admin).call_with_text(line_user_id: line_user_id, text: "Please click the following URL to authenticate your Google account.\n\n#{auth_url(user)}")
            else
              Line::SaveSentMessage.new(admin).call_with_text(line_user_id: line_user_id, text: "Please enter the correct value.")
            end
          rescue => e
            3.times do
              puts "An Error occurred!!!"
            end
            puts e
            Line::SaveSentMessage.new(admin).call_with_text(
              line_user_id: line_user_id,
              text: "Sorry, an error occurred on the server.\nPlease contact the system administrator or click the following URL to authenticate your Google account again.\n\n#{auth_url(user)}"
            )
          end
        # case event.type
        # when Line::Bot::Event::MessageType::Text
        end
      end
    end

    render plain: 'success!', status: :ok
  end

  private
  def auth_url(user)
    return "https://#{ENV['HOST']}/calendar/auth/#{user.id}"
  end
end
