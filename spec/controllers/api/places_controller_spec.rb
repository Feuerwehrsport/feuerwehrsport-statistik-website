require 'rails_helper'

RSpec.describe API::PlacesController, type: :controller do
  let(:place) { create(:place) }

  describe 'POST create' do
    subject { -> { post :create, place: { name: 'Wurstort' } } }

    it 'creates new place', login: :sub_admin do
      expect do
        subject.call
        expect_api_login_response
      end.to change(Place, :count).by(1)
      expect_change_log(after: { name: 'Wurstort' }, log: 'create-place')
    end
    it_behaves_like 'api user get permission error'
  end

  describe 'GET show' do
    it 'returns place' do
      get :show, id: place.id
      expect_json_response
      expect(json_body[:place]).to eq(
        id: place.id,
        name: 'Charlottenthal',
      )
    end
  end

  describe 'GET index' do
    before { place }
    it 'returns places' do
      get :index
      expect_json_response
      expect(json_body[:places].first).to eq(id: place.id, name: 'Charlottenthal')
    end
  end

  describe 'PUT update' do
    subject { -> { put :update, id: place.id, place: { latitude: '123', longitude: '456' } } }

    it 'update place', login: :api do
      subject.call
      expect_json_response
      expect(json_body[:place]).to eq(
        id: place.id,
        name: 'Charlottenthal',
      )
      expect(Place.find(place.id).latitude).to eq 123
      expect(Place.find(place.id).longitude).to eq 456
      expect_change_log(before: {}, after: {}, log: 'update-place')
    end
  end
end
