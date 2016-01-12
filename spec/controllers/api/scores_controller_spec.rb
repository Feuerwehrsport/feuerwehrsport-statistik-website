require 'rails_helper'

RSpec.describe API::ScoresController, type: :controller do
  describe 'PUT update' do
    it "update score", login: :api do
      put :update, id: 111, score: { team_id: "44" }
      expect_json_response
      expect(json_body[:score]).to include(team_id: 44)
      expect(Score.find(111).team_id).to eq 44
    end
  end
end