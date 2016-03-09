require 'rails_helper'

RSpec.describe API::Series::RoundsController, type: :controller do
  describe 'GET index' do
    it "returns rounds" do
      get :index
      expect_json_response
      expect(json_body[:series_rounds].first).to eq(
        aggregate_type: "DCup",
        id: 1,
        name: "D-Cup",
        year: 2015,
      )
    end
  end
end