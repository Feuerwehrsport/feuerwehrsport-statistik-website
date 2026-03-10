# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::Series::TeamAssessments' do
  let!(:assessment) { create(:series_team_assessment) }

  describe 'GET index' do
    it 'returns assessments', login: :admin do
      get '/api/series/team_assessments'
      expect_json_response
      expect(json_body[:series_team_assessments].first).to eq(
        key: 'female',
        discipline: 'la',
        round_id: assessment.round_id,
        id: assessment.id,
        name: 'Frauen',
      )
    end
  end
end
