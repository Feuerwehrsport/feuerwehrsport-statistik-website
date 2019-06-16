require 'rails_helper'

RSpec.describe YearsController, type: :controller do
  let!(:competition) { create(:competition) }
  let!(:score) { create(:score, :double) }
  let!(:group_score) { create(:group_score, :double) }

  describe 'GET index' do
    it 'assigns collection' do
      get :index
      expect(response).to be_success
      expect(controller.send(:collection).length).to eq 1
    end
  end

  describe 'GET show' do
    it 'assigns resource' do
      get :show, params: { id: competition.date.year }
      expect(response).to be_success
      expect(controller.send(:resource).year).to eq Year.first.year
    end
  end

  describe 'GET best_performance' do
    it 'assigns resource' do
      get :best_performance, params: { id: competition.date.year }
      expect(response).to be_success
      expect(controller.send(:resource).year).to eq Year.first.year
      expect(assigns(:performance_overview_disciplines)).to have(2).items
    end
  end

  describe 'GET best_scores' do
    it 'assigns resource' do
      get :best_scores, params: { id: competition.date.year }
      expect(response).to be_success
      expect(controller.send(:resource).year).to eq Year.first.year
      expect(assigns(:discipline_structs)).to have(2).items
    end
  end
end
