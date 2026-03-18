# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::Series::TeamParticipations' do
  let(:participation) { create(:series_team_participation) }

  describe 'POST create' do
    let(:r) { -> { post '/api/series/team_participations', params: { series_team_participation: attributes } } }

    let(:cup) { create(:series_cup) }
    let(:assessment) { create(:series_team_assessment) }
    let(:team) { create(:team) }

    let(:attributes) do
      { cup_id: cup.id, team_assessment_id: assessment.id, team_id: team.id, team_number: 1, team_gender: 1,
        time: '1234', rank: '22', points: '22' }
    end

    it 'creates new participation', login: :admin do
      expect do
        r.call
        expect_api_login_response(created_id: Series::TeamParticipation.last.id)
      end.to change(Series::TeamParticipation, :count).by(1)
      expect_change_log(after: { points: 22 }, log: 'create-series-teamparticipation')
    end

    it_behaves_like 'api user get permission error'
    it_behaves_like 'sub_admin get permission error'
  end

  describe 'GET show'  do
    let(:r) { -> { get "/api/series/team_participations/#{participation.id}" } }

    it 'returns participation', login: :admin do
      r.call
      expect_json_response
      expect(json_body[:series_team_participation]).to eq(
        team_assessment_id: participation.team_assessment_id,
        cup_id: participation.cup_id,
        id: participation.id,
        team_id: participation.team_id,
        team_number: 1,
        team_gender: 1,
        points: 15,
        rank: 2,
        second_time: '18,99',
        time: 1899,
        points_correction: nil,
        points_correction_hint: nil,
      )
    end
  end

  describe 'GET index' do
    before { participation }

    it 'returns participations' do
      get '/api/series/team_participations'
      expect_json_response
      expect(json_body[:series_team_participations].first).to eq(
        team_assessment_id: participation.team_assessment_id,
        cup_id: participation.cup_id,
        id: participation.id,
        team_id: participation.team_id,
        team_number: 1,
        team_gender: 1,
        points: 15,
        rank: 2,
        second_time: '18,99',
        time: 1899,
        points_correction: nil,
        points_correction_hint: nil,
      )
    end
  end

  describe 'PUT update' do
    let(:r) do
      -> {
        put "/api/series/team_participations/#{participation.id}", params: { series_team_participation: attributes }
      }
    end

    let(:attributes) { { team_id: create(:team).id, time: 1234, rank: 22, points: 22 } }

    it 'updates participation', login: :admin do
      r.call
      expect(json_body[:series_team_participation]).to include attributes
      expect_change_log(before: { points: 15 }, after: { points: 22 }, log: 'update-series-teamparticipation')
    end

    it_behaves_like 'api user get permission error'
    it_behaves_like 'sub_admin get permission error'
  end

  describe 'DELETE destroy' do
    let(:r) { -> { delete "/api/series/team_participations/#{participation.id}" } }

    before { participation }

    it 'destroys participation', login: :admin do
      expect do
        r.call
        expect_json_response
      end.to change(Series::TeamParticipation, :count).by(-1)
      expect_change_log(before: { points: 15 }, log: 'destroy-series-teamparticipation')
    end

    it_behaves_like 'api user get permission error'
    it_behaves_like 'sub_admin get permission error'
  end
end
