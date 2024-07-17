module Line
  class SaveSentMessage
    def initialize(admin, user)
      @admin = admin
      @user = user
      raise ArgumentError, 'User must be present' unless user.present?
    end

    def call_with_text(text:)
      send_message(text)
      save_message(text)
    end

    private

    def send_message(text)
      ::Line::Api::Push.new(@admin).call_with_text(user: @user, text: text)
    end
    def save_message(text)
      resource = MessageText.new(content: text)
      Message.create!(sendable: @admin, receivable: @user, resource: resource)
    end
  end
end