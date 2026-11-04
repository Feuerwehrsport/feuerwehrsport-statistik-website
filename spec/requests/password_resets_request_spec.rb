# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Password resets' do
  let(:login) { create(:login, :expired) }

  it 'requests a password reset mail' do
    get '/password_reset/new'
    expect(response).to be_successful

    expect do
      post '/password_reset', params: { password_reset: { email_address: login.email_address.upcase } }
    end.to have_enqueued_mail(LoginMailer, :password_reset)
    expect(response).to redirect_to('/password_reset')
    follow_redirect!
    expect(response.body).to include('E-Mail versendet')
  end

  it 'reports unknown email addresses' do
    expect do
      post '/password_reset', params: { password_reset: { email_address: 'unknown@example.com' } }
    end.not_to have_enqueued_mail
    expect(response).to have_http_status(:unprocessable_content)
  end

  it 'sets a new password with a valid token' do
    token = login.password_reset_token
    get "/password_reset/#{token}/edit"
    expect(response).to be_successful

    patch "/password_reset/#{token}",
          params: { password_reset: { password: 'NewSecret1', password_confirmation: 'NewSecret1' } }
    expect(response).to redirect_to('/session/new')
    expect(login.reload.authenticate('NewSecret1')).to be_truthy
    expect(login).not_to be_expired

    get "/password_reset/#{token}/edit"
    expect(response).to have_http_status(:not_found)
  end

  it 'shows errors for not matching passwords' do
    patch "/password_reset/#{login.password_reset_token}",
          params: { password_reset: { password: 'NewSecret1', password_confirmation: 'other' } }
    expect(response).to have_http_status(:unprocessable_content)
    expect(login.reload.authenticate('Secret123')).to be_truthy
  end

  it 'rejects invalid tokens' do
    get '/password_reset/invalid/edit'
    expect(response).to have_http_status(:not_found)
  end

  describe 'expired login' do
    it 'explains why a new password is needed and sends reset mail' do
      get '/expired_login/new', params: { email_address: login.email_address }
      expect(response.body).to include('Um die Sicherheit Ihres Nutzerkontos zu erhöhen')
      expect(response.body).to include(login.email_address)

      expect do
        post '/expired_login', params: { password_reset: { email_address: login.email_address } }
      end.to have_enqueued_mail(LoginMailer, :password_reset)
      expect(response).to redirect_to('/expired_login')
    end
  end
end
