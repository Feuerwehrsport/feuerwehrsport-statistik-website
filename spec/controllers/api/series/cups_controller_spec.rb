require 'rails_helper'

RSpec.describe API::Series::CupsController, type: :controller do
  describe 'GET index' do
    it "returns cups" do
      get :index
      expect_json_response
      expect(json_body[:series_cups].first).to eq(
        competition_id: 90,
        date: "2009-04-25",
        id: 43,
        place: "Ventschow",
        round_id: 18,
      )
    end
  end
end