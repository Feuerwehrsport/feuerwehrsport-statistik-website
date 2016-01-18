require 'rails_helper'

RSpec.describe API::ScoresController, type: :controller do
  describe 'GET show' do
    it "returns score" do
      get :show, id: 1
      expect_json_response

      expect(json_body[:score]).to eq(
        id: 1, 
        team_id: 1, 
        team_number: 0, 
        time: 2179, 
        discipline: "hb", 
        second_time: "21,79", 
        translated_discipline_name: "Hindernisbahn", 
        person: "Mareen Klos",
        similar_scores: [
          {
            id: 1, 
            time: 2179, 
            second_time: "21,79", 
            discipline: "hb", 
            translated_discipline_name: "Hindernisbahn", 
            team_id: 1, 
            team_number: 0
          }, {
            id: 39, 
            time: 2148, 
            second_time: "21,48", 
            discipline: "hb", 
            translated_discipline_name: "Hindernisbahn", 
            team_id: 1, 
            team_number: 0
          }
        ],
      )
    end
  end

  describe 'PUT update' do
    subject { -> { put :update, id: 111, score: { team_id: "44", team_number: "-2" } } }
    it "update score", login: :api do
      subject.call
      expect_json_response
      expect(json_body[:score]).to include(team_id: 44, team_number: -2)
      expect(Score.find(111).team_id).to eq 44
    end
  end
end