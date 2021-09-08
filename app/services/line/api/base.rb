module Line::Api
  class Base
    BASE_URL = 'https://access.line.me'
    ENDPOINT = 'https://api.line.me'

    def initialize(admin)
      @admin = admin
    end

    private
    def conn
      @conn ||= Faraday.new(url: ENDPOINT)
    end

    def handle_error(res)
      puts res.status
      if res.status != 200
        msg = <<~MSG
        status_code: #{res.status}
        body: #{res.body}
        MSG
        # raise Line::ApiError, msg
        raise RuntimeError
      end

      return res
    end
  end
end