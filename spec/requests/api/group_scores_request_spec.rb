# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::GroupScores' do
  let(:group_score) { create(:group_score, :double) }

  describe 'GET show' do
    it 'returns group_score' do
      get "/api/group_scores/#{group_score.id}"
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
            person_1_first_name: nil,
            person_1_last_name: nil,
            person_2: nil,
            person_2_first_name: nil,
            person_2_last_name: nil,
            person_3: nil,
            person_3_first_name: nil,
            person_3_last_name: nil,
            person_4: nil,
            person_4_first_name: nil,
            person_4_last_name: nil,
            person_5: nil,
            person_5_first_name: nil,
            person_5_last_name: nil,
            person_6: nil,
            person_6_first_name: nil,
            person_6_last_name: nil,
            person_7: nil,
            person_7_first_name: nil,
            person_7_last_name: nil,
          },
          {
            id: group_score.team.group_scores.last.id,
            time: 2345,
            second_time: '23,45',
            person_1: nil,
            person_1_first_name: nil,
            person_1_last_name: nil,
            person_2: nil,
            person_2_first_name: nil,
            person_2_last_name: nil,
            person_3: nil,
            person_3_first_name: nil,
            person_3_last_name: nil,
            person_4: nil,
            person_4_first_name: nil,
            person_4_last_name: nil,
            person_5: nil,
            person_5_first_name: nil,
            person_5_last_name: nil,
            person_6: nil,
            person_6_first_name: nil,
            person_6_last_name: nil,
            person_7: nil,
            person_7_first_name: nil,
            person_7_last_name: nil,
          },
        ],
      )
    end
  end

  describe 'PUT update' do
    let(:r) { -> { put "/api/group_scores/#{group_score.id}", params: { group_score: { team_id: team.id } } } }

    let(:team) { create(:team) }

    it 'update group_score', login: :sub_admin do
      r.call
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
    let(:persons_in) do
      {
        person_1: p1.id,
        person_2: p2.id,
        person_3: p3.id,
        person_4: p4.id,
        person_5: 'NULL',
        person_6: p6.id,
        person_7: 9_999_999_999,
      }
    end
    let(:persons_out) do
      {
        person_1: p1.id,
        person_1_first_name: p1.first_name,
        person_1_last_name: p1.last_name,
        person_2: p2.id,
        person_2_first_name: p2.first_name,
        person_2_last_name: p2.last_name,
        person_3: p3.id,
        person_3_first_name: p3.first_name,
        person_3_last_name: p3.last_name,
        person_4: p4.id,
        person_4_first_name: p4.first_name,
        person_4_last_name: p4.last_name,
        person_5: nil,
        person_5_first_name: nil,
        person_5_last_name: nil,
        person_6: p6.id,
        person_6_first_name: p6.first_name,
        person_6_last_name: p6.last_name,
        person_7: nil,
        person_7_first_name: nil,
        person_7_last_name: nil,
      }
    end

    it 'updates person_participations', login: :api do
      put "/api/group_scores/#{group_score.id}/person_participation", params: {
        group_score: persons_in, log_action: 'update-groupscore:participation'
      }
      expect_json_response
      expect(json_body[:group_score]).to include(
        similar_scores: [
          persons_out.merge(id: group_score.id, time: 2287, second_time: '22,87'),
          {
            id: group_score.team.group_scores.last.id,
            time: 2345,
            second_time: '23,45',
            person_1: nil,
            person_1_first_name: nil,
            person_1_last_name: nil,
            person_2: nil,
            person_2_first_name: nil,
            person_2_last_name: nil,
            person_3: nil,
            person_3_first_name: nil,
            person_3_last_name: nil,
            person_4: nil,
            person_4_first_name: nil,
            person_4_last_name: nil,
            person_5: nil,
            person_5_first_name: nil,
            person_5_last_name: nil,
            person_6: nil,
            person_6_first_name: nil,
            person_6_last_name: nil,
            person_7: nil,
            person_7_first_name: nil,
            person_7_last_name: nil,
          },
        ],
      )
      expect_change_log(after: { time: 2287 }, log: 'update-groupscore:participation')
    end
  end
end
