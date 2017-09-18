require 'rails_helper'

RSpec.describe API::Series::AssessmentsController, type: :controller do
  let!(:assessment) { create(:series_person_assessment) }
  describe 'GET index' do
    it 'returns assessments' do
      get :index
      expect_json_response
      expect(json_body[:series_assessments].first).to eq(
        discipline: 'hl',
        gender: 'male',
        id: assessment.id,
        name: 'Hakenleitersteigen - männlich',
        real_name: '',
        round_id: assessment.round_id,
        gender_translated: 'männlich',
        type: 'Series::PersonAssessment',
      )
    end
  end
end
