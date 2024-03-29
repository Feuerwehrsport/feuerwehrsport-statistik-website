# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::Places' do
  let(:place) { create(:place) }

  describe 'POST create' do
    let(:r) { -> { post '/api/places', params: { place: { name: 'Wurstort' } } } }

    it 'creates new place', login: :sub_admin do
      expect do
        r.call
        expect_api_login_response(created_id: Place.last.id)
      end.to change(Place, :count).by(1)
      expect_change_log(after: { name: 'Wurstort' }, log: 'create-place')
    end

    it_behaves_like 'api user get permission error'
  end

  describe 'GET show' do
    it 'returns place' do
      get "/api/places/#{place.id}"
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
      get '/api/places'
      expect_json_response
      expect(json_body[:places].first).to eq(id: place.id, name: 'Charlottenthal')
    end
  end

  describe 'PUT update' do
    let(:r) { -> { put "/api/places/#{place.id}", params: { place: { latitude: '123', longitude: '456' } } } }

    it 'update place', login: :api do
      r.call
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
