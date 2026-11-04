# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Backend::Registrations' do
  let(:login_attributes) do
    {
      name: 'Neuer Nutzer',
      email_address: 'Neu@Example.com',
      password: 'Secret123',
      password_confirmation: 'Secret123',
    }
  end

  describe 'GET new' do
    it 'shows registration form' do
      get '/backend/registration/new'
      expect(response).to be_successful
      expect(response.body).to include('admin_users_registration[login_attributes][email_address]')
    end
  end

  describe 'POST create' do
    def register(attributes = login_attributes)
      post '/backend/registration', params: { admin_users_registration: { login_attributes: attributes } }
    end

    it 'creates user with role user, sends verify mail and logs in' do
      expect { register }.to have_enqueued_mail(LoginMailer, :verify)
      expect(AdminUser.count).to eq 1
      expect(Login.count).to eq 1

      admin_user = AdminUser.last
      expect(admin_user.role).to eq :user
      expect(admin_user.email_address).to eq 'neu@example.com'
      expect(admin_user.name).to eq 'Neuer Nutzer'
      expect(admin_user.login).not_to be_verified
      expect(session[:login_id]).to eq admin_user.login.id
      expect(response).to redirect_to('/backend')
      expect(flash[:success]).to be_present
    end

    it 'ignores role parameter' do
      post '/backend/registration', params: {
        admin_users_registration: { role: 'admin', login_attributes: },
      }
      expect(AdminUser.last.role).to eq :user
    end

    it 'redirects to requested url before login' do
      get '/backend/import_requests/decide_login'
      expect(response).to be_successful
      expect(response.body).to include('Konto erstellen')
      expect(session[:requested_url_before_login]).to eq '/backend/import_requests/decide_login'

      register
      expect(response).to redirect_to('/backend/import_requests/decide_login')
    end

    it 'does not register with invalid data' do
      expect do
        register(login_attributes.merge(password_confirmation: 'other'))
      end.not_to change(AdminUser, :count)
      expect(response).to have_http_status(:ok)
      expect(session[:login_id]).to be_nil
    end

    it 'does not register existing email address twice' do
      register
      reset!
      expect do
        register(login_attributes.merge(email_address: 'neu@example.com'))
      end.not_to change(AdminUser, :count)
    end
  end
end
