require 'rails_helper'

RSpec.describe PagesController, type: :controller do
  describe 'GET dashboard' do
    it "assigns a lot information" do
      get :dashboard
      expect(assigns(:last_competitions).count).to eq 8
      expect(assigns(:people_count)).to eq 2178
      expect(assigns(:score_valid_count)).to eq 48669
      expect(assigns(:score_invalid_count)).to eq 4516
      expect(assigns(:places_count)).to eq 311
      expect(assigns(:events_count)).to eq 20
      expect(assigns(:competitions_count)).to eq 916
      expect(assigns(:teams_count)).to eq 2155
      expect(assigns(:years_count).count).to eq 28
      expect(assigns(:news).count).to eq 2
      expect(assigns(:performance_overview_disciplines).count).to eq 7
      expect(assigns(:charts)).to be_instance_of Chart::Dashboard
    end
  end

  describe 'GET last_competitions' do
    it "assigns the 100 last competitions" do
      get :last_competitions_overview
      expect(assigns(:last_competitions).count).to eq 100
      expect(assigns(:last_competitions).first).to eq Competition.find(920)
    end
  end

  describe 'GET firesport_overview' do
    it "assigns nothing" do
      get :firesport_overview
    end
  end

  describe 'GET wettkampf_manager' do
    it "assigns wettkampf_manager_versions" do
      get :wettkampf_manager
      expect(assigns(:wettkampf_manager_versions).count).to eq 3
    end
  end
end