module Line
  class SaveReceivedMessage
    def initialize(admin, user)
      @admin = admin
      @user = user
    end

    def call(event)
      resource = MessageText.new(content: event.message['text'])
      Message.create!(sendable: @user, receivable: @admin, resource: resource)
    end
  end
end