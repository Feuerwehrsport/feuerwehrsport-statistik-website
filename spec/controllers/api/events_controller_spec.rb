require 'rails_helper'

RSpec.describe API::EventsController, type: :controller do
  describe 'GET index' do
    it "returns events" do
      get :index
      expect_json_response
      expect(json_body[:events].first).to eq(id: 15, name: "Amtsausscheid")
    end
  end
end