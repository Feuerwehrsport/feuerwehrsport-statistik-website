# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Verifications' do
  let(:login) { create(:login, :not_verified) }

  it 'verifies the email address once' do
    token = login.generate_token_for(:verification)
    get "/verify_login/#{token}"
    expect(response).to redirect_to('/session/new')
    expect(flash[:info]).to eq 'E-Mail-Adresse erfolgreich verifiziert'
    expect(login.reload).to be_verified

    get "/verify_login/#{token}"
    expect(flash[:alert]).to include('ungültig')
  end

  it 'rejects invalid tokens' do
    get '/verify_login/invalid'
    expect(response).to redirect_to('/session/new')
    expect(login.reload).not_to be_verified
  end
end
