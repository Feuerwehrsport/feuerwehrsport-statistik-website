require 'rails_helper'

RSpec.describe Series::AssessmentsController, type: :controller do
  let!(:assessment) { create(:series_person_assessment) }

  describe 'GET show' do
    it 'assigns resource' do
      get :show, id: assessment.id
      expect(controller.send(:resource)).to be_a Series::Assessment
    end
  end
end
