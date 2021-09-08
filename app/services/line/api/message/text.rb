module Line::Api::Message
  class Text
    def initialize(texts)
      @texts = texts
    end

    def request_body
      messages = @texts.map {|text|
        {
          type: 'text',
          text: text
        }
      }

      return {messages: messages}
    end
  end
end
