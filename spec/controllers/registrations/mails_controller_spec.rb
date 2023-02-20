# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Registrations::MailsController, login: :user do
  let!(:competition) { create(:registrations_competition, admin_user: login_user) }
  let!(:team) { create(:registrations_team, competition: competition) }
  let(:mail_params) { { subject: 'subject', text: 'text', add_registration_file: true } }

  describe 'GET new' do
    it 'redirects' do
      get :new, params: { competition_id: competition.id }
      expect(response).to be_successful
    end
  end

  describe 'POST create' do
    it 'saves' do
      expect do
        post :create, params: { competition_id: competition.id, registrations_mail: mail_params }
        expect(response).to redirect_to(registrations_competition_path(competition))
      end.to change(ActionMailer::Base.deliveries, :count).by(1)
    end
  end
end
