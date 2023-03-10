# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'M3::Login::Sessions' do
  let(:login) { create(:m3_login) }
  let(:login_redirect_url) { { action: :show } }

  describe 'GET new' do
    it 'returns http success' do
      get '/session/new'
      expect(response).to be_successful
    end
  end

  describe 'POST create' do
    let(:r) do
      -> {
        post '/session', params: { m3_login_session: { email_address:, password: } }
      }
    end

    let(:password) { login.password }
    let(:email_address) { login.email_address }

    context 'when credentials are not correct' do
      let(:password) { 'incorrect' }

      it 'signs in' do
        expect(&r).not_to have_enqueued_job
        expect(controller.instance_variable_get(:@form_resource).errors[:password].count).to eq 1
        expect(response).to be_successful
        expect(session['m3_login_id']).to be_nil
      end
    end

    context 'when login not exists' do
      let(:password) { '' }
      let(:email_address) { 'not-exists@example.com' }

      it 'signs in' do
        expect(&r).not_to have_enqueued_job
        expect(controller.instance_variable_get(:@form_resource).errors[:password].count).to eq 1
        expect(response).to be_successful
        expect(session['m3_login_id']).to be_nil
      end
    end

    context 'when credentials are correct' do
      it 'signs in' do
        expect(&r).not_to have_enqueued_job
        expect(response).to redirect_to(login_redirect_url)
        expect(session['m3_login_id']).to eq login.id
      end

      context 'when login not verified' do
        let(:login) { create(:m3_login, :not_verified) }

        it 'resend mail' do
          expect(&r).to have_enqueued_job.exactly(:once).and have_enqueued_job(ActionMailer::MailDeliveryJob)
          expect(response).to be_successful
          expect(controller.session['m3_login_id']).to be_nil
        end
      end

      context 'when login expired' do
        let(:login) { create(:m3_login, :expired) }

        it 'resend mail' do
          expect(&r).not_to have_enqueued_job
          expect(response).to redirect_to(controller: 'm3/login/expired_logins',
                                          action: :new,
                                          email_address: login.email_address)
          expect(controller.session['m3_login_id']).to be_nil
        end
      end
    end
  end

  describe 'GET show' do
    context 'when logged in', login: :user do
      it 'returns http success' do
        get '/session'
        expect(response).to redirect_to backend_root_path
      end
    end

    context 'when not logged in' do
      it 'redirects to new' do
        get('/session')
        expect(response).to redirect_to(action: :new)
      end
    end
  end
end
