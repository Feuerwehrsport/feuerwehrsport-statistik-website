require 'rails_helper'

RSpec.describe API::GroupScoresController, type: :controller do
  let(:group_score) { create(:group_score, :double) }
  describe 'GET show' do
    it 'returns group_score' do
      get :show, id: group_score.id
      expect_json_response
      expect(json_body[:group_score]).to eq(
        id: group_score.id,
        team_id: group_score.team_id,
        team_number: 1,
        gender: 'male',
        time: 2287,
        group_score_category_id: group_score.group_score_category_id,
        run: nil,
        discipline: 'la',
        second_time: '22,87',
        translated_discipline_name: 'Löschangriff nass',
        similar_scores: [
          {
            id: group_score.id,
            time: 2287,
            second_time: '22,87',
            person_1: nil,
            person_2: nil,
            person_3: nil,
            person_4: nil,
            person_5: nil,
            person_6: nil,
            person_7: nil,
          },
          {
            id: group_score.team.group_scores.last.id,
            time: 2345,
            second_time: '23,45',
            person_1: nil,
            person_2: nil,
            person_3: nil,
            person_4: nil,
            person_5: nil,
            person_6: nil,
            person_7: nil,
          },
        ],
      )
    end
  end

  describe 'PUT update' do
    let(:team) { create(:team) }
    subject { -> { put :update, id: group_score.id, group_score: { team_id: team.id } } }
    it 'update group_score', login: :sub_admin do
      subject.call
      expect_json_response
      expect(json_body[:group_score]).to include(team_id: team.id)
      expect(GroupScore.find(group_score.id).team_id).to eq team.id
      expect_change_log(before: { time: 2287 }, after: { team_id: team.id }, log: 'update-groupscore')
    end
    it_behaves_like 'api user get permission error'
  end

  describe 'PUT person_participation' do
    let(:p1) { create(:person) }
    let(:p2) { create(:person) }
    let(:p3) { create(:person) }
    let(:p4) { create(:person) }
    let(:p6) { create(:person) }
    let(:persons_in) { { person_1: p1.id, person_2: p2.id, person_3: p3.id, person_4: p4.id, person_5: 'NULL', person_6: p6.id, person_7: 9_999_999_999 } }
    let(:persons_out) { { person_1: p1.id, person_2: p2.id, person_3: p3.id, person_4: p4.id, person_5: nil, person_6: p6.id, person_7: nil } }

    it 'updates person_participations', login: :api do
      put :person_participation, id: group_score.id, group_score: persons_in, log_action: 'update-groupscore:participation'
      expect_json_response
      expect(json_body[:group_score]).to include(
        similar_scores: [
          persons_out.merge(id: group_score.id, time: 2287, second_time: '22,87'),
          {
            id: group_score.team.group_scores.last.id,
            time: 2345,
            second_time: '23,45',
            person_1: nil,
            person_2: nil,
            person_3: nil,
            person_4: nil,
            person_5: nil,
            person_6: nil,
            person_7: nil,
          },
        ],
      )
      expect_change_log(after: { time: 2287 }, log: 'update-groupscore:participation')
    end
  end
end
