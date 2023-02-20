# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Backend::RegistrationsController, type: :controller do
  describe 'GET new' do
    it 'shows new form' do
      get :new
      expect(response).to be_successful
    end
  end

  describe 'POST create' do
    let(:attributes) { { name: 'Test user', email_address: 'test@user.de', password: 'a', password_confirmation: 'a' } }

    it 'creates new admin user' do
      expect do
        post :create, params: { admin_users_registration: { login_attributes: attributes } }
        expect(response).to redirect_to backend_root_path
      end.to change(AdminUser, :count).by(1)
    end
  end
end
