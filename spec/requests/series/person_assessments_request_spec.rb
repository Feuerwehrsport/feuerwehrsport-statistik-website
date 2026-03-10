# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Series::PersonAssessments' do
  let!(:assessment) { create(:series_person_assessment) }

  describe 'GET show' do
    it 'assigns resource' do
      get "/series/person_assessments/#{assessment.id}"
      expect(controller.send(:resource)).to be_a Series::PersonAssessment
      expect(response).to be_successful
      expect(response.content_type).to eq 'text/html; charset=utf-8'
    end

    context 'when pdf requested' do
      it 'sends pdf' do
        get "/series/person_assessments/#{assessment.id}.pdf"
        expect(controller.send(:resource)).to be_a Series::PersonAssessment
        expect(response).to be_successful
        expect(response.content_type).to eq 'application/pdf'
        expect(response.headers['Content-Disposition']).to eq(
          "inline; filename=\"hakenleitersteigen-frauen.pdf\"; filename*=UTF-8''hakenleitersteigen-frauen.pdf",
        )
      end
    end
  end
end
