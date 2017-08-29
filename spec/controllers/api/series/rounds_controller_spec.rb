require 'rails_helper'

RSpec.describe API::Series::RoundsController, type: :controller do
  let(:attributes) { { name: 'Cup', year: 2017, official: true, aggregate_type: 'LaCup', full_cup_count: 4 } }
  describe 'POST create' do
    subject { -> { post :create, series_round: attributes } }
    it 'creates new round', login: :admin do
      expect {
        subject.call
        expect_api_login_response
      }.to change(Series::Round, :count).by(1)
    end
    it_behaves_like "api user get permission error"
    it_behaves_like "sub_admin get permission error"
  end

  describe 'PUT update' do
    subject { -> { put :update, id: 1, series_round: attributes } }
    it 'update round', login: :admin do
      subject.call
      expect_json_response
      expect(Series::Round.first.official).to eq true
    end
    it_behaves_like "api user get permission error"
    it_behaves_like "sub_admin get permission error"
  end

  describe 'GET show' do
    it "returns round" do
      get :show, id: 1
      expect_json_response
      expect(json_body[:series_round]).to eq(
        aggregate_type: "DCup",
        id: 1,
        name: "D-Cup",
        year: 2015,
        full_cup_count:4,
        official: false,
      )
    end
  end

  describe 'GET index' do
    it "returns rounds" do
      get :index
      expect_json_response
      expect(json_body[:series_rounds].first).to eq(
        aggregate_type: "DCup",
        id: 1,
        name: "D-Cup",
        year: 2015,
        full_cup_count:4,
        official: false,
      )
    end
  end
end