module Line
  class SaveReceivedMessage
    def initialize(admin, user)
      @admin = admin
      @user = user
    end

    def call(event)
      resource = MessageText.new(content: event.message['text'])
      Message.create!(sendable: @user, receivable: @admin, resource: resource)
    rescue => e
      handle_error(e)
    end

    private

    def send_message(text)
      Line::SaveSentMessage.new(@admin, @user).call_with_text(text: text)
    end

    def handle_error(e)
      puts("An unexpected error occurred: #{e.message}")
      send_message("Sorry, Message creation failed due to an unexpected error.")
    end
  end
end