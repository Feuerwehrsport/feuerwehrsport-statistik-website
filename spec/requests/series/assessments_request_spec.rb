# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Series::Assessments' do
  let!(:assessment) { create(:series_person_assessment) }

  describe 'GET show' do
    it 'assigns resource' do
      get "/series/assessments/#{assessment.id}"
      expect(controller.send(:resource)).to be_a Series::Assessment
      expect(response).to be_successful
      expect(response.content_type).to eq 'text/html; charset=utf-8'
    end

    context 'when pdf requested' do
      it 'sends pdf' do
        get "/series/assessments/#{assessment.id}.pdf"
        expect(controller.send(:resource)).to be_a Series::Assessment
        expect(response).to be_successful
        expect(response.content_type).to eq 'application/pdf'
        expect(response.headers['Content-Disposition']).to eq(
          "inline; filename=\"hakenleitersteigen-mannlich.pdf\"; filename*=UTF-8''hakenleitersteigen-mannlich.pdf",
        )
      end
    end
  end
end
