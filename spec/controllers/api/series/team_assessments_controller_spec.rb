require 'rails_helper'

RSpec.describe API::Series::TeamAssessmentsController, type: :controller do
  describe 'GET index' do
    it "returns assessments", login: :admin do
      get :index
      expect_json_response
      expect(json_body[:series_team_assessments].first).to eq(
        translated_gender: "weiblich", 
        name: "Löschangriff nass - weiblich", 
        discipline: "la", 
        round_id: 15,
        id: 2,
      )
    end
  end
end