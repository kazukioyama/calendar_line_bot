module Line
  # GoogleCalendarAPIに依存しない形にしたい
  class MessageProcesser
    def initialize(admin, user, event)
      @admin = admin
      @user = user
      @event = event
    end

    def handle_message
      case @event[:message][:text]
      when "Hello"
        send_message("Hi! Thank you for using me.")
        send_message("Please click the following URL to authenticate your Google account.\n\n#{auth_url}")
      when "Get Upcoming Event"
        events = fetch_events(1)
        send_messages(events)
      when "Get 10 Events"
        events = fetch_events(10)
        send_messages(events)
      when "Switch Between Google Accounts"
        send_message("Please click the following URL to authenticate your Google account.\n\n#{auth_url}")
      else
        send_message("Please enter the correct value.")
      end
    rescue => e
      handle_error(e)
    end
  end

  private

  def send_messages(messages)
    messages.each do |message|
      send_message(message)
    end
  end

  def send_message(text)
    Line::SaveSentMessage.new(@admin, @user).call_with_text(text: text)
  end

  def fetch_events(count)
    events_list = Calendar::GoogleCalendar.new(@user).get_events(count)
    events_list[:summary]
  end

  def auth_url
    "https://#{ENV['HOST']}/calendar/auth/#{@user.id}"
  end

  def handle_error(exception)
    logger.error("An unexpected error occurred: #{exception.message}")
    send_message("Sorry, an error occurred on the server.\nPlease contact the system administrator or click the following URL to authenticate your Google account again.\n\n#{auth_url}")
  end
end
end