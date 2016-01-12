require 'rails_helper'

RSpec.describe API::PlacesController, type: :controller do
  describe 'POST create' do
    it "creates new place", login: :api do
      expect {
        post :create, place: { name: "Wurstort" }
        expect_api_response
      }.to change(Place, :count).by(1)
    end
  end

  describe 'GET show' do
    it "returns place" do
      get :show, id: 1
      expect_json_response
      expect(json_body[:place]).to eq(
        id: 1,
        name: "Charlottenthal",
      )
    end
  end

  describe 'GET index' do
    it "returns places" do
      get :index
      expect_json_response
      expect(json_body[:places].first).to eq(id: 26, name: "Antalya (TR)")
    end
  end

  describe 'PUT update' do
    it "update place", login: :api do
      put :update, id: 1, place: { latitude: "123", longitude: "456" }
      expect_json_response
      expect(json_body[:place]).to eq(
        id: 1,
        name: "Charlottenthal",
      )
      expect(Place.find(1).latitude).to eq 123
      expect(Place.find(1).longitude).to eq 456
    end
  end
end