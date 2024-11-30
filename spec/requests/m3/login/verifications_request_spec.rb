# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'M3::Login::Verifications' do
  let(:login) { create(:m3_login) }

  describe 'GET verify' do
    let(:login) { create(:m3_login, :not_verified) }

    context 'when token is correct' do
      it 'redirects to login' do
        get "/verify_login/#{login.verify_token}"
        expect(response).to redirect_to(Rails.application.config.m3.session.login_url)
        login.reload
        expect(login.verified_at).not_to be_nil
      end
    end

    context 'when token is invalid' do
      it 'returns http success' do
        get '/verify_login/other-token'
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
