require 'rails_helper'

RSpec.describe CompetitionsController, type: :controller do
  describe 'GET index' do
    it "assigns rows" do
      get :index
      expect(assigns(:competitions).count).to eq 304
      expect(assigns(:chart)).to be_instance_of(Chart::CompetitionsScoreOverview)
      expect(assigns(:competitions_discipline_overview).count).to eq 3
    end
  end

  describe 'GET show' do
    it "assigns competition" do
      get :show, id: 1
      expect(assigns(:competition)).to eq Competition.find(1)
      expect(assigns(:calc)).to be_instance_of Calculation::Competition
    end
  end

  describe 'POST files' do
    let(:testfile) { fixture_file_upload('testfile.pdf', 'application/pdf') }
    it "creates files" do
      expect {
        post :files, id: 1, competition_file: { "0" => { file: testfile, hl_male: "1", hb_female: "1" } }
      }.to change(CompetitionFile, :count).by(1)
      expect(assigns(:competition)).to eq Competition.find(1)
      expect(response).to be_success
      expect(CompetitionFile.last.keys).to match_array ["hl_male", "hb_female"]
    end
  end
end