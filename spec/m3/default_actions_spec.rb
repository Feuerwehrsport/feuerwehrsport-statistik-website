# frozen_string_literal: true

require 'rails_helper'

# DefaultActions (m3/app/controllers/concerns/default_actions*) tested through a simple backend controller
RSpec.describe 'M3 DefaultActions', type: :request do
  let!(:place) { create(:place) }

  context 'when not logged in' do
    it 'redirects to login and remembers requested url' do
      get '/backend/admin_users'
      expect(response).to redirect_to('/session/new')
      expect(flash[:alert]).to be_present
      expect(session[:requested_url_before_login]).to eq '/backend/admin_users'
    end

    it 'allows reading of public resources' do
      get '/backend/places'
      expect(response).to be_successful
    end

    it 'does not create resources' do
      expect do
        post '/backend/places', params: { place: { name: 'Rostock' } }
      end.not_to change(Place, :count)
      expect(response).to redirect_to('/session/new')
    end
  end

  context 'when logged in without permissions', login: :user do
    it 'redirects to root with access denied' do
      get '/backend/admin_users'
      expect(response).to redirect_to('/')
      expect(flash[:alert]).to eq 'Keine Rechte zum Anzeigen der Seite'
    end

    it 'does not destroy resources' do
      expect do
        delete "/backend/places/#{place.id}"
      end.not_to change(Place, :count)
      expect(response).to redirect_to('/')
    end
  end

  context 'when logged in with permissions', login: :sub_admin do
    describe 'index' do
      before { create_list(:place, 11) { |p, i| p.name = "Ort #{i.to_s.rjust(2, '0')}" } }

      it 'paginates collection' do
        get '/backend/places'
        expect(response).to be_successful
        expect(controller.send(:collection).to_a.size).to eq 10

        get '/backend/places', params: { page: 2 }
        expect(controller.send(:collection).to_a.size).to eq 2
      end
    end

    describe 'new' do
      it 'prefills form with given params' do
        get '/backend/places/new', params: { place: { name: 'Vorbelegt' } }
        expect(response).to be_successful
        expect(response.body).to include('value="Vorbelegt"')
      end
    end

    describe 'create' do
      it 'renders form again with invalid params' do
        expect do
          post '/backend/places', params: { place: { name: '' } }
        end.not_to change(Place, :count)
        expect(response).to have_http_status(:ok)
        expect(flash[:alert]).to be_present
        expect(response.body).to include('form')
      end

      it 'redirects to return page when rtp given' do
        post '/backend/places', params: { place: { name: 'Rostock' }, rtp: '/backend/teams' }
        expect(response).to redirect_to('/backend/teams')
      end

      it 'does not redirect to foreign hosts with rtp' do
        expect do
          post '/backend/places', params: { place: { name: 'Rostock' }, rtp: 'https://evil.example.com/' }
        end.to raise_error(ActionController::Redirecting::UnsafeRedirectError)
      end
    end

    describe 'edit' do
      it 'prefills form with given params' do
        get "/backend/places/#{place.id}/edit", params: { place: { name: 'Geändert' } }
        expect(response).to be_successful
        expect(response.body).to include('value="Geändert"')
      end

      it 'raises not found for unknown ids' do
        get '/backend/places/999999/edit'
        expect(response).to have_http_status(:not_found)
      end
    end

    describe 'update' do
      it 'renders form again with invalid params' do
        patch "/backend/places/#{place.id}", params: { place: { name: '' } }
        expect(response).to have_http_status(:ok)
        expect(flash[:alert]).to be_present
        expect(place.reload.name).to eq 'Charlottenthal'
      end
    end
  end
end
