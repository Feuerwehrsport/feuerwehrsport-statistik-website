# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::Series::PersonParticipations' do
  let(:participation) { create(:series_person_participation) }

  describe 'GET index' do
    before { participation }

    it 'returns participations' do
      get '/api/series/person_participations'
      expect_json_response
      expect(json_body[:series_person_participations].first).to eq(
        person_assessment_id: participation.person_assessment_id,
        cup_id: participation.cup_id,
        id: participation.id,
        person_id: participation.person_id,
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
