# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::Series::PersonAssessments' do
  let!(:assessment) { create(:series_person_assessment) }

  describe 'GET index' do
    it 'returns assessments', login: :admin do
      get '/api/series/person_assessments'
      expect_json_response
      expect(json_body[:series_person_assessments].first).to eq(
        key: 'female',
        discipline: 'hl',
        round_id: assessment.round_id,
        id: assessment.id,
      )
    end
  end
end
