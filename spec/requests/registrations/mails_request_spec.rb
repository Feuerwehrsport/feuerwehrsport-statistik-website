# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Registrations::Mails', login: :user do
  let!(:competition) { create(:registrations_competition, admin_user: login_user) }
  let!(:band) { create(:registrations_band, competition:) }
  let!(:team) { create(:registrations_team, band:) }
  let(:mail_params) { { subject: 'subject', text: 'text', add_registration_file: true } }

  describe 'GET new' do
    it 'redirects' do
      get "/registrations/competitions/#{competition.id}/mail/new"
      expect(response).to be_successful
    end
  end

  describe 'POST create' do
    it 'saves' do
      expect do
        post "/registrations/competitions/#{competition.id}/mail", params: { registrations_mail: mail_params }
        expect(response).to redirect_to(registrations_competition_path(competition))
      end.to have_enqueued_job.exactly(:once).and have_enqueued_job(ActionMailer::MailDeliveryJob)
    end
  end
end
