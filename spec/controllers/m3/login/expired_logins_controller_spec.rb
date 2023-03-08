# frozen_string_literal: true

require 'rails_helper'

RSpec.describe M3::Login::ExpiredLoginsController, website: :default do
  let(:login) { create(:m3_login) }

  describe 'GET new' do
    it 'returns http success' do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST create' do
    subject { -> { post :create, params: { m3_login_expired_login: { email_address: email_address } } } }

    let(:email_address) { login.email_address }

    context 'when credentials are not correct' do
      let(:email_address) { 'incorrect@example.com' }

      it 'renders new' do
        expect do
          subject.call
        end.not_to change { ActionMailer::Base.deliveries.count }
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:new)
      end
    end

    context 'when credentials are correct' do
      it 'creates passsword reset' do
        expect do
          subject.call
        end.to change { ActionMailer::Base.deliveries.count }.by(1)
        expect(response).to redirect_to(action: :index)
        login.reload
        expect(login.password_reset_requested_at).not_to be_nil
        expect(login.password_reset_token).not_to be_nil
      end
    end
  end
end
