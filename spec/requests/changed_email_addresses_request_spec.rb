# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Changed email addresses' do
  let(:login) { create(:login, changed_email_address: 'new@example.com') }
  let(:token) { login.generate_token_for(:email_change) }

  it 'shows old and new address and confirms the change' do
    get "/changed_email_addresses/#{token}/edit"
    expect(response).to be_successful
    expect(response.body).to include('my_account1994@gmail.com', 'new@example.com')

    patch "/changed_email_addresses/#{token}"
    expect(response).to redirect_to('/session/new')
    expect(login.reload.email_address).to eq 'new@example.com'

    get "/changed_email_addresses/#{token}/edit"
    expect(response).to have_http_status(:not_found)
  end

  it 'rejects tokens after a newer change request' do
    old_token = token
    login.update!(new_email_address: 'other@example.com')
    get "/changed_email_addresses/#{old_token}/edit"
    expect(response).to have_http_status(:not_found)
  end
end
