# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::ApiUsers' do
  describe 'GET status' do
    context 'when session is not set' do
      it 'returns login false' do
        post '/api/api_users/status'
        expect_api_not_login_response
      end
    end

    context 'when session user id is set', login: :api do
      it 'returns login true' do
        post '/api/api_users/status'
        expect_api_login_response
      end
    end
  end

  describe 'POST create' do
    let(:login_user) { ApiUser.new(name: 'hans') }

    it 'creates new user and sign in' do
      expect do
        post '/api/api_users', params: { api_user: { name: 'hans', email_address: 'email-address@foo.de' } }
      end.to change(ApiUser, :count).by(1)
      expect_api_login_response
    end

    context 'when email_address is not valid' do
      it 'fails to create new user' do
        post '/api/api_users', params: { api_user: { name: 'hans', email_address: 'not-valid' } }
        expect_api_not_login_response success: false, message: 'E-Mail-Adresse ist nicht gültig'
      end
    end
  end

  describe 'POST logout' do
    before do
      post '/api/api_users', params: { api_user: { name: 'hans', email_address: 'email-address@foo.de' } }
    end

    it 'log user out' do
      post '/api/api_users/logout'
      expect_api_not_login_response
    end
  end
end
