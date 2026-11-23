# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Backend::UncheckedPlaces', login: :sub_admin do
  let!(:unchecked_place) { create(:place, name: 'Gr. Laasch', checked_at: nil) }
  let!(:checked_place) { create(:place, name: 'Warin', latitude: 53.8, longitude: 11.7, checked_at: Time.current) }

  describe 'GET index' do
    it 'lists only unchecked places' do
      get '/backend/unchecked_places'
      expect(response).to be_successful
      expect(controller.send(:collection).to_a).to eq [UncheckedPlace.find(unchecked_place.id)]
    end
  end

  describe 'GET show' do
    let!(:similar_place) do
      create(:place, name: 'Groß Laasch', latitude: 53.4, longitude: 11.5, checked_at: Time.current)
    end

    it 'shows similar places and the place search' do
      get "/backend/unchecked_places/#{unchecked_place.id}"
      expect(response).to be_successful
      expect(response.body).to include('Mögliche Duplikate', 'gleicher Name', 'Mit anderem Ort zusammenführen')
      expect(response.body).to include(%(name="correct_place_id" value="#{similar_place.id}"))
      expect(response.body).to include('data-controller="lookup"',
                                       "/contributions/places/#{unchecked_place.id}/geo_position/edit")
    end

    it 'does not find checked places' do
      get "/backend/unchecked_places/#{checked_place.id}"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST merge' do
    it 'moves the competitions and removes the place' do
      competition = create(:competition, place: unchecked_place)
      import_request = create(:import_request, import_request_files: [], place: unchecked_place)
      post "/backend/unchecked_places/#{unchecked_place.id}/merge", params: { correct_place_id: checked_place.id }
      expect(response).to redirect_to('/backend/unchecked_places')
      expect(Place.exists?(unchecked_place.id)).to be false
      expect(competition.reload.place).to eq checked_place
      expect(import_request.reload.place).to eq checked_place
      expect(ChangeLog.last).to have_attributes(action: 'merge', model_class: 'Place')
    end

    it 'keeps the position of the merged place' do
      unchecked_place.update!(latitude: 53.4, longitude: 11.5)
      target = create(:place, name: 'Laasch')
      post "/backend/unchecked_places/#{unchecked_place.id}/merge", params: { correct_place_id: target.id }
      expect(target.reload.latlon).to eq [53.4, 11.5]
    end
  end

  describe 'PUT update' do
    it 'redirects to index after marking as checked' do
      put "/backend/unchecked_places/#{unchecked_place.id}", params: { unchecked_place: { checked_at: Time.current } }
      expect(response).to redirect_to(action: :index)
      expect(unchecked_place.reload.checked_at).to be_present
    end
  end

  context 'when logged in as simple user', login: :user do
    it 'denies index and merge' do
      get '/backend/unchecked_places'
      expect(response).to redirect_to('/')

      post "/backend/unchecked_places/#{unchecked_place.id}/merge", params: { correct_place_id: checked_place.id }
      expect(Place.exists?(unchecked_place.id)).to be true
    end
  end
end
