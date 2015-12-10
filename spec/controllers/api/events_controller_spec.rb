require 'rails_helper'

RSpec.describe API::EventsController, type: :controller do
  describe 'GET index' do
    it "returns events" do
      get :index
      expect_json_response
      expect(json_body[:events].first).to include id: 1, name: "D-Cup"
    end
  end
end