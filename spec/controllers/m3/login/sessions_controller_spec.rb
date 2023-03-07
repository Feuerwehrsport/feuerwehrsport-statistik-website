# frozen_string_literal: true

require 'rails_helper'

RSpec.describe M3::Login::SessionsController, website: :default do
  let(:show_redirects_to_url) { backend_root_path }
  let(:login) { create(:m3_login) }
  let(:login_redirect_url) { { action: :show } }
  let(:params) { {} }
  let(:param_name) { :m3_login_session }

  describe 'GET new' do
    it 'returns http success' do
      get :new, params: params
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST create' do
    subject do
      -> {
        post :create, params: params.merge(param_name => { email_address: email_address,
                                                           password: password })
      }
    end

    let(:password) { login.password }
    let(:email_address) { login.email_address }

    context 'when credentials are not correct' do
      let(:password) { 'incorrect' }

      it 'signs in' do
        expect do
          subject.call
        end.not_to change { ActionMailer::Base.deliveries.count }
        expect(assigns(:form_resource).errors[:password].count).to eq 1
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:new)
        expect(session['m3_login_id']).to be_nil
      end
    end

    context 'when login not exists' do
      let(:password) { '' }
      let(:email_address) { 'not-exists@example.com' }

      it 'signs in' do
        expect do
          subject.call
        end.not_to change { ActionMailer::Base.deliveries.count }
        expect(assigns(:form_resource).errors[:password].count).to eq 1
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:new)
        expect(session['m3_login_id']).to be_nil
      end
    end

    context 'when credentials are correct' do
      it 'signs in' do
        expect do
          subject.call
        end.not_to change { ActionMailer::Base.deliveries.count }
        expect(response).to redirect_to(login_redirect_url)
        expect(session['m3_login_id']).to eq login.id
      end

      context 'when login not verified' do
        let(:login) { create(:m3_login, :not_verified) }

        it 'resend mail' do
          expect do
            subject.call
          end.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(response).to have_http_status(:success)
          expect(response).to render_template(:new)
          expect(session['m3_login_id']).to be_nil
        end
      end

      context 'when login expired' do
        let(:login) { create(:m3_login, :expired) }

        it 'resend mail' do
          expect do
            subject.call
          end.not_to change { ActionMailer::Base.deliveries.count }
          expect(response).to redirect_to(controller: 'm3/login/expired_logins',
                                          action: :new,
                                          email_address: login.email_address)
          expect(session['m3_login_id']).to be_nil
        end
      end
    end
  end

  describe 'GET show' do
    context 'when logged in' do
      it 'returns http success' do
        get :show, params: params, session: { m3_login_id: login.id }
        if show_redirects_to_url
          expect(response).to redirect_to show_redirects_to_url
        else
          expect(response).to have_http_status(:success)
        end
      end
    end

    context 'when not logged in' do
      it 'redirects to new' do
        get :show, params: params
        expect(response).to redirect_to(action: :new)
      end
    end
  end

  describe 'DELETE destroy' do
    it 'returns http success' do
      delete :destroy, params: params, session: { m3_login_id: login.id }
      expect(response).to redirect_to(root_path)
      expect(session['m3_login_id']).to be_nil
    end
  end
end
