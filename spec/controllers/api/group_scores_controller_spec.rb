require 'rails_helper'

RSpec.describe API::GroupScoresController, type: :controller do
  describe 'GET show' do
    it "returns group_score" do
      get :show, id: 1
      expect_json_response
      expect(json_body[:group_score]).to eq(
        discipline: "la",
        gender: "male",
        group_score_category_id: 30,
        id: 1,
        run: "",
        second_time: "22,39",
        similar_scores: [
          { id: 1, time: 2239, second_time: "22,39", person_1: 235, person_2: 153, person_3: 146, person_4: 1529, 
            person_5: 156, person_6: 148, person_7: 444 },
          { id: 2, time: 2704, second_time: "27,04", person_1: 235, person_2: 153, person_3: 146, person_4: 1529, 
            person_5: 156, person_6: 148, person_7: 444 }
        ],
        team_id: 13,
        team_number: 0,
        time: 2239,
        translated_discipline_name: "Löschangriff nass",
      )
    end
  end

  describe 'PUT person_participation' do
    let(:persons_in) { {  person_1: 1, person_2: 2, person_3: 3, person_4: 4, person_5: "NULL", person_6: 6, person_7: 9999999999 } }
    let(:persons_out) { { person_1: 1, person_2: 2, person_3: 3, person_4: 4, person_5: nil,    person_6: 6, person_7: nil } }

    it "updates person_participations" do
      put :person_participation, id: 1, group_score: persons_in
      expect_json_response
      expect(json_body[:group_score]).to include(
        similar_scores: [
          persons_out.merge(id: 1, time: 2239, second_time: "22,39"),
          { id: 2, time: 2704, second_time: "27,04", person_1: 235, person_2: 153, person_3: 146, person_4: 1529, 
            person_5: 156, person_6: 148, person_7: 444 }
        ],
      )
    end
  end
end