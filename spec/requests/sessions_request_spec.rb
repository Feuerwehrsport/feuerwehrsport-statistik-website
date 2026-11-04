# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sessions' do
  let(:login) { create(:login) }
  let!(:admin_user) { create(:admin_user, :user, login:) }

  def sign_in(email_address: login.email_address, password: 'Secret123')
    post '/session', params: { session: { email_address:, password: } }
  end

  it 'shows the login form' do
    get '/session/new'
    expect(response).to be_successful
    expect(response.body).to include('Passwort vergessen?')
  end

  it 'signs in and redirects to the backend' do
    sign_in
    expect(response).to redirect_to('/backend')
    expect(session[:login_id]).to eq login.id
    follow_redirect!
    expect(response).to be_successful
  end

  it 'redirects to the url requested before login' do
    get '/backend/admin_users'
    expect(response).to redirect_to('/session/new')
    sign_in
    expect(response).to redirect_to('/backend/admin_users')
  end

  it 'rejects wrong passwords' do
    sign_in(password: 'wrong')
    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include('E-Mail-Adresse oder Passwort ist falsch.')
    expect(session[:login_id]).to be_nil
  end

  context 'when login is not verified' do
    let(:login) { create(:login, :not_verified) }

    it 'resends verification mail' do
      expect { sign_in }.to have_enqueued_mail(LoginMailer, :verify)
      expect(response).to have_http_status(:unprocessable_content)
      expect(session[:login_id]).to be_nil
    end
  end

  context 'when login is expired' do
    let(:login) { create(:login, :expired) }

    it 'redirects to expired login page' do
      sign_in
      expect(response).to redirect_to("/expired_login/new?email_address=#{CGI.escape(login.email_address)}")
      expect(session[:login_id]).to be_nil
    end
  end

  it 'signs out' do
    sign_in
    delete '/session'
    expect(response).to redirect_to('/session/new')
    expect(session[:login_id]).to be_nil
    get '/session'
    expect(response).to redirect_to('/session/new')
  end

  it 'redirects logged in users from login form to backend' do
    sign_in
    get '/session/new'
    expect(response).to redirect_to('/backend')
  end

  it 'limits login attempts' do
    11.times { sign_in(password: 'wrong') }
    expect(response).to redirect_to('/session/new')
    expect(flash[:alert]).to include('Zu viele Anmeldeversuche')
  end
end
