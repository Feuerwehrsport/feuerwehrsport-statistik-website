require 'rails_helper'

RSpec.describe CompetitionsController, type: :controller do
  describe 'GET index' do
    it "assigns rows" do
      get :index
      expect(assigns(:competitions).count).to eq 916
      expect(assigns(:chart)).to be_instance_of(Chart::CompetitionsScoreOverview)
      expect(assigns(:competitions_discipline_overview).count).to eq 9
    end
  end

  describe 'GET show' do
    it "assigns competition" do
      get :show, id: 1
      expect(assigns(:competition)).to eq Competition.find(1)
      expect(assigns(:calc)).to be_instance_of Calculation::Competition
    end
  end
end