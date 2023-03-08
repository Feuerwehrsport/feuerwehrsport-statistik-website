# frozen_string_literal: true

require 'rails_helper'

RSpec.describe M3::Login::VerificationsController, website: :default do
  let(:login) { create(:m3_login) }

  describe 'GET verify' do
    let(:login) { create(:m3_login, :not_verified) }

    context 'when token is correct' do
      it 'redirects to login' do
        get :verify, params: { token: login.verify_token }
        expect(response).to redirect_to(Rails.application.config.m3.session.login_url)
        login.reload
        expect(login.verified_at).not_to be_nil
      end
    end

    context 'when token is invalid' do
      it 'returns http success' do
        expect do
          get :verify, params: { token: 'other-token' }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
