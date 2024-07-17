module Line
  # GoogleCalendarAPIに依存しない形にしたい
  class MessageProcesser
    include Rails.application.routes.url_helpers

    def initialize(admin, user, event)
      @admin = admin
      @user = user
      @event = event
    end

    def handle_message
      case @event.message['text']
      when "Hello"
        send_message("Hi! Thank you for using me.")
        send_message("Please click the following URL to authenticate your Google account.\n\n#{auth_url(@user)}")
      when "Get Upcoming Event"
        events = fetch_events(1)
        send_messages(events)
      when "Get 10 Events"
        events = fetch_events(10)
        send_messages(events)
      when "Switch Between Google Accounts"
        send_message("Please click the following URL to authenticate your Google account.\n\n#{auth_url(@user)}")
      else
        send_message("Please enter the correct value.")
      end
    rescue => e
      handle_error(e)
    end

    private

    def send_messages(messages)
      messages.each do |message|
        send_message(message)
      end
    end

    def send_message(text)
      ::Line::SaveSentMessage.new(@admin, @user).call_with_text(text: text)
    end

    def fetch_events(count)
      events_list = Calendar::GoogleCalendar.new(@user).get_events(count)
      events_list[:summary]
    end

    def auth_url(user)
      auth_google_oauth_index_url(user_id: user.id)
    end

    def handle_error(e)
      puts("An unexpected error occurred: #{e.message}")
      send_message("Sorry, an error occurred on the server.\nPlease contact the system administrator or click the following URL to authenticate your Google account again.\n\n#{auth_url(@user)}")
    end
  end
end