class CalendarController < ApplicationController
  def callback
    # service = Google::Apis::CalendarV3::CalendarService.new
    # service.client_options.application_name = APPLICATION_NAME

    # # 受け取ったトークンをAPIのclientにブチ込む
    # client = Signet::OAuth2::Client.new(
    #   client_id: CLIENT_ID,
    #   client_secret: CLIENT_SECRET,
    #   access_token: access_token,
    #   refresh_token: refresh_token,
    #   token_credential_uri: 'https://accounts.google.com/o/oauth2/token'
    # )
    # # client.refresh!
    # service.authorization = client

    # calendar_id = "primary"
    # response = service.list_events(calendar_id,
    #                               max_results:   10,
    #                               single_events: true,
    #                               order_by:      "startTime",
    #                               time_min:      DateTime.now.rfc3339)
    # puts "Upcoming events:"
    # puts "No upcoming events found" if response.items.empty?
    # events_list = {summary: []}
    # response.items.each do |event|
    #   start = event.start.date || event.start.date_time
    #   puts "- #{event.summary} (#{start})"
    #   events_list[:summary] << "#{event.summary} (#{start})"
    # end

    # render :json => events_list
  end
end