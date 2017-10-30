require 'rails_helper'

RSpec.describe CompetitionsController, type: :controller do
  let!(:score) { create(:score) }

  describe 'GET index' do
    it 'assigns collection' do
      get :index
      expect(response).to be_success
      expect(controller.send(:collection).count).to eq 1
      expect(assigns(:chart)).to be_instance_of(Chart::CompetitionsScoreOverview)
      expect(assigns(:competitions_discipline_overview).count).to eq 1
    end
  end

  describe 'GET show' do
    it 'assigns resource' do
      get :show, id: score.competition.id
      expect(response).to be_success
      expect(controller.send(:resource)).to eq score.competition
      expect(assigns(:calc)).to be_instance_of Calculation::Competition
    end
  end
end
