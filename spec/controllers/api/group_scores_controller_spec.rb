require 'rails_helper'

RSpec.describe API::GroupScoresController, type: :controller do
  describe 'GET show' do
    it "returns group_score" do
      get :show, id: 3
      expect_json_response
      expect(json_body[:group_score]).to eq(
        id: 3,
        team_id: 10,
        team_number: 0,
        gender: "male",
        time: 2287,
        group_score_category_id: 30,
        run: "",
        discipline: "la",
        second_time: "22,87",
        translated_discipline_name: "Löschangriff nass",
        similar_scores: [
          {
            id: 3,
            time: 2287,
            second_time: "22,87",
            person_1: nil,
            person_2: 69,
            person_3: 88,
            person_4: 57,
            person_5: nil,
            person_6: nil,
            person_7: nil
          },
          {
            id: 4,
            time: 2659,
            second_time: "26,59",
            person_1: nil,
            person_2: 69,
            person_3: 88,
            person_4: 57,
            person_5: nil,
            person_6: nil,
            person_7: nil
          }
        ]
      )
    end
  end

  describe 'PUT update' do
    subject { -> { put :update, id: 111, group_score: { team_id: "44" } } }
    it "update group_score", login: :sub_admin do
      subject.call
      expect_json_response
      expect(json_body[:group_score]).to include(team_id: 44)
      expect(GroupScore.find(111).team_id).to eq 44
    end
    it_behaves_like "api user get permission error"
  end

  describe 'PUT person_participation' do
    let(:persons_in) { {  person_1: 1, person_2: 2, person_3: 3, person_4: 4, person_5: "NULL", person_6: 6, person_7: 9999999999 } }
    let(:persons_out) { { person_1: 1, person_2: 2, person_3: 3, person_4: 4, person_5: nil,    person_6: 6, person_7: nil } }

    it "updates person_participations", login: :api do
      put :person_participation, id: 3, group_score: persons_in
      expect_json_response
      expect(json_body[:group_score]).to include(
        similar_scores: [
          persons_out.merge(id: 3, time: 2287, second_time: "22,87"),
          {
            id: 4,
            time: 2659,
            second_time: "26,59",
            person_1: nil,
            person_2: 69,
            person_3: 88,
            person_4: 57,
            person_5: nil,
            person_6: nil,
            person_7: nil
          }
        ],
      )
    end
  end
end