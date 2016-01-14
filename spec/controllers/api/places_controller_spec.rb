require 'rails_helper'

RSpec.describe API::PlacesController, type: :controller do
  describe 'POST create' do
    subject { -> { post :create, place: { name: "Wurstort" } } }
    it "creates new place", login: :sub_admin do
      expect {
        subject.call
        expect_api_login_response
      }.to change(Place, :count).by(1)
    end
    it_behaves_like "api user get permission error"
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
    subject { -> { put :update, id: 1, place: { latitude: "123", longitude: "456" } } }
    it "update place", login: :api do
      subject.call
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