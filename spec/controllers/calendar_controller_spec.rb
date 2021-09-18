require 'rails_helper'

RSpec.describe CalendarController, type: :controller do
  describe "GET calendar/auth/1" do
    before do
      @params = {user_id: '1'}
    end
    it "returns a 302 response" do
      get :auth, params: @params
      expect(response).to have_http_status "302"
    end
  end

end
