module Calendar
  class GoogleCalendar
    require "google/apis/calendar_v3"
    require "signet/oauth_2/client"

    CLIENT_ID = ENV['CLIENT_ID']
    CLIENT_SECRET = ENV['CLIENT_SECRET']

    def initialize(user)
      @user = user
    end

    def get_events(max_num)
      # docs: https://developers.google.com/calendar/api/v3/reference/events/list

      service = set_client
      calendar_id = "primary"
      response = service.list_events(calendar_id,
                                    max_results:   max_num,
                                    single_events: true,
                                    order_by:      "startTime",
                                    time_min:      DateTime.now.rfc3339)
      puts "Upcoming events:"
      puts "No upcoming events found" if response.items.empty?
      events_list = {summary: []}
      response.items.each do |event|
        start = event.start.date || event.start.date_time
        puts "- #{event.summary} (#{start})"
        events_list[:summary] << "#{event.summary} (#{start})"
      end

      return events_list
    end

    private
    def set_client
      service = Google::Apis::CalendarV3::CalendarService.new
      service.client_options.application_name = "Google Calendar API Ruby Quickstart"

      access_token = @user.google_access_token
      refresh_token = @user.google_refresh_token

      # 受け取ったトークンをAPIのclientにブチ込む
      client = Signet::OAuth2::Client.new(
        client_id: CLIENT_ID,
        client_secret: CLIENT_SECRET,
        access_token: access_token,
        refresh_token: refresh_token,
        token_credential_uri: 'https://accounts.google.com/o/oauth2/token'
      )
      # client.refresh!
      service.authorization = client

      return service
    end
  end
end