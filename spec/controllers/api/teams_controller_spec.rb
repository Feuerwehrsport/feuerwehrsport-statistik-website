require 'rails_helper'

RSpec.describe API::TeamsController, type: :controller do
  describe 'POST create' do
    it "creates new team", login: :api do
      expect {
        post :create, team: { name: "Mannschaft1", shortcut: "Mann1", status: "fire_station" }
        expect_api_response
      }.to change(Team, :count).by(1)
    end
  end

  describe 'GET show' do
    it "returns team" do
      get :show, id: 1
      expect(json_body[:team]).to eq(
        id: 1,
        latitude: "52.5611297253",
        longitude: "14.0714263916",
        name: "FF Buckow",
        shortcut: "Buckow",
        state: "BB",
        status: "fire_station",
      )
    end
  end

  describe 'GET index' do
    it "returns teams" do
      get :index
      expect_json_response
      expect(json_body[:teams].first).to include(id: 2255, name: "Amt Dorf Meckl/Bd. Kl.")
    end
  end

  describe 'PUT update' do
    it "updates team" do
      put :update, id: 1, team: { latitude: "12", longitude: "34" }
      expect(json_body[:team]).to eq(
        id: 1,
        latitude: "12.0",
        longitude: "34.0",
        name: "FF Buckow",
        shortcut: "Buckow",
        state: "BB",
        status: "fire_station",
      )
    end
  end
end