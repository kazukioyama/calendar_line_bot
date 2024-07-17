class WebhookController < ApplicationController
  protect_from_forgery with: :null_session # CSRF許可

  def create
    body = request.body.read #LINE側から送信されたリクエストボディ

    begin
      admin = Admin.find(params[:admin_id])
    rescue ActiveRecord::RecordNotFound => e
      render json: { message: "Admin not found: #{e.message}" }, status: :not_found
    rescue => e
      puts e
      render json: { message: 'Internal Server error' }, status: :internal_server_error
    end

    bot = Line::Api::Bot.new(admin)

    begin
      # 署名の検証（LINEプラットフォームからのリクエストか判定するため）
      unless bot.validate_signature?(body, request.env['HTTP_X_LINE_SIGNATURE'])
        raise Line::InvalidSignatureError
      end
    rescue Line::InvalidSignatureError => e
      render json: { message: 'Invalid signature error' }, status: :unauthorized
    rescue => e
      puts e
      render json: { message: 'Internal Server error' }, status: :internal_server_error
    end

    # リクエストボディをパースする
    events = bot.parse_events_from(body)

    line_user_id = events[0]['source']['userId']

    begin
      user = User.find_or_create_by!(line_user_id: line_user_id)
    rescue ActiveRecord::RecordInvalid => e
      puts "User creation failed: #{e.message}"
      render json: { message: 'Internal Server error' }, status: :internal_server_error
    end

    # 処理中のメッセージを返す
    Line::SaveSentMessage.new(admin, user).call_with_text(text: "Processing...")

    events.each do |event|
      case event
      when Line::Bot::Event::Message
        begin
          Line::SaveReceivedMessage.new(admin, user).call(event) # 受け取ったメッセージをDBに保存
        rescue ActiveRecord::RecordInvalid => e
          puts "User creation failed: #{e.message}"
          Line::SaveSentMessage.new(admin, user).call_with_text(
            text: "Sorry, User creation failed."
          )
          return
        rescue => e
          puts "An unexpected error occurred: #{e.message}"
          Line::SaveSentMessage.new(admin, user).call_with_text(
            text: "Sorry, Message creation failed due to an unexpected error."
          )
          return
        end
        begin
          # 受け取ったメッセージ内容によって処理を分岐
          case event["message"]["text"]
          when "Hello" # 初期セッティング
            Line::SaveSentMessage.new(admin, user).call_with_text(text: "Hi! Thank you for using me.")
            Line::SaveSentMessage.new(admin, user).call_with_text(text: "Please click the following URL to authenticate your Google account.\n\n#{auth_url(user)}")
          when "Get Upcoming Event"
            if user.google_access_token.nil?
              Line::SaveSentMessage.new(admin, user).call_with_text(
                text: "Please click the following URL to authenticate your Google account.\n\n#{auth_url(user)}"
              )
            end
            events_list = Calendar::GoogleCalendar.new(user).get_events(1)
            events_list[:summary].each do |value|
              Line::SaveSentMessage.new(admin, user).call_with_text(text: value)
            end
          when "Get 10 Events"
            if user.google_access_token.nil?
              Line::SaveSentMessage.new(admin, user).call_with_text(
                text: "Please click the following URL to authenticate your Google account.\n\n#{auth_url(user)}"
              )
            end
            events_list = Calendar::GoogleCalendar.new(user).get_events(10)
            events_list[:summary].each do |value|
              Line::SaveSentMessage.new(admin, user).call_with_text( text: value)
            end
          when "Switch Between Google Accounts"
            Line::SaveSentMessage.new(admin, user).call_with_text(text: "Please click the following URL to authenticate your Google account.\n\n#{auth_url(user)}")
          else
            Line::SaveSentMessage.new(admin, user).call_with_text(text: "Please enter the correct value.")
          end
        rescue => e
          3.times do
            puts "An Error occurred!!!"
          end
          puts e
          Line::SaveSentMessage.new(admin, user).call_with_text(
            text: "Sorry, an error occurred on the server.\nPlease contact the system administrator or click the following URL to authenticate your Google account again.\n\n#{auth_url(user)}"
          )
          return
        end
      end
    end

    render plain: 'success!', status: :ok
  end

  private
  # TODO: _path(user_id: user.id)の形でヘルパーメソッドで渡すようにする
  def auth_url(user)
    "https://#{ENV['HOST']}/calendar/auth/#{user.id}"
  end
end
