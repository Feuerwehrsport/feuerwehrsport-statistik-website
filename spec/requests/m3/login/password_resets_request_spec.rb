# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'M3::Login::PasswordResets' do
  let(:old_password) { 'password123' }
  let(:new_password) { 'new-password123' }
  let(:login) { create(:m3_login, password: old_password) }

  describe 'GET new' do
    it 'returns http success' do
      get '/password_reset/new'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST create' do
    let(:r) { -> { post '/password_reset', params: { m3_login_password_reset: { email_address: } } } }

    let(:email_address) { login.email_address }

    context 'when credentials are not correct' do
      let(:email_address) { 'incorrect' }

      it 'renders new' do
        expect(&r).not_to have_enqueued_job
        expect(response).to be_successful
      end
    end

    context 'when credentials are correct' do
      it 'creates password reset' do
        expect(&r).to have_enqueued_job.exactly(:once).and have_enqueued_job(ActionMailer::MailDeliveryJob)
        expect(response).to redirect_to(action: :index)
        login.reload
        expect(login.password_reset_requested_at).not_to be_nil
        expect(login.password_reset_token).not_to be_nil
      end
    end
  end

  describe 'GET edit' do
    context 'when token is correct' do
      let(:login) { create(:m3_login, :with_password_reset_token, password: old_password) }

      it 'returns http success' do
        get "/password_reset/#{login.password_reset_token}/edit"
        expect(response).to have_http_status(:success)
      end
    end

    context 'when token ist correct, but to old' do
      it 'returns' do
        get "/password_reset/#{login.password_reset_token}/edit"
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'PATCH update' do
    let(:login) { create(:m3_login, :with_password_reset_token, expired_at: Time.current, password: old_password) }

    it 'returns http success' do
      patch "/password_reset/#{login.password_reset_token}", params: {
        m3_login_password_reset: { password: new_password, password_confirmation: new_password },
      }
      expect(response).to redirect_to(Rails.application.config.m3.session.login_url)
      login.reload
      expect(login.authenticate(new_password)).to be_truthy
      expect(login.expired_at).to be_nil
    end
  end
end
