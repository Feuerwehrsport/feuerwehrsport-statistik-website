# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Backend::Dashboards' do
  describe 'GET index' do
    it 'successes' do
      get '/backend'
      expect(response).to redirect_to(new_session_path)
    end

    context 'with admin', login: :admin do
      it 'shows link to admin jobs' do
        get '/backend'
        expect(response.body).to include('href="/admin-jobs"')
      end
    end

    context 'with sub admin', login: :sub_admin do
      it 'hides link to admin jobs' do
        get '/backend'
        expect(response).to have_http_status(:ok)
        expect(response.body).not_to include('href="/admin-jobs"')
      end
    end
  end
end
