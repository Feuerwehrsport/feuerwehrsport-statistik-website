# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::Series::TeamParticipations' do
  let(:participation) { create(:series_team_participation) }

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
end
