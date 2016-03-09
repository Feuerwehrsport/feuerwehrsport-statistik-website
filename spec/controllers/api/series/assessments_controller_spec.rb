require 'rails_helper'

RSpec.describe API::Series::AssessmentsController, type: :controller do
  describe 'GET index' do
    it "returns assessments" do
      get :index
      expect_json_response
      expect(json_body[:series_assessments].first).to eq(
        discipline: "hl",
        gender: "male",
        id: 1,
        name: "Hakenleitersteigen - männlich",
        real_name: "",
        round_id: 11,
        translated_gender: "männlich",
        type: "Series::PersonAssessment",
      )
    end
  end
end