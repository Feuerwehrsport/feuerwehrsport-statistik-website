# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'M3::Login::ExpiredLogins' do
  let(:login) { create(:m3_login) }

  describe 'GET new' do
    it 'returns http success' do
      get '/expired_login/new'
      expect(response).to be_successful
    end
  end

  describe 'POST create' do
    let(:r) { -> { post '/expired_login', params: { m3_login_expired_login: { email_address: } } } }

    let(:email_address) { login.email_address }

    context 'when credentials are not correct' do
      let(:email_address) { 'incorrect@example.com' }

      it 'renders new' do
        expect(&r).not_to have_enqueued_job
        expect(response).to be_successful
      end
    end

    context 'when credentials are correct' do
      it 'creates passsword reset' do
        expect(&r).to have_enqueued_job.exactly(:once).and have_enqueued_job(ActionMailer::MailDeliveryJob)
        expect(response).to redirect_to(action: :index)
        login.reload
        expect(login.password_reset_requested_at).not_to be_nil
        expect(login.password_reset_token).not_to be_nil
      end
    end
  end
end
