# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Registrations::TeamCreations', login: :user do
  let(:competition) { create(:registrations_competition) }
  let(:band) { create(:registrations_band, competition:) }
  let(:team_attrs) { { name: 'FF Warin', shortcut: 'Warin', gender: :male } }

  describe 'GET new' do
    it 'redirects' do
      get "/registrations/bands/#{band.id}/team_creation/new"
      expect(response).to be_successful
      expect(controller.parent_url).to eq registrations_competition_url(competition)
    end
  end

  describe 'POST create' do
    it 'saves' do
      expect do
        expect do
          post "/registrations/bands/#{band.id}/team_creation", params: { registrations_team: team_attrs }
          expect(response).to(redirect_to(edit_registrations_band_team_path(band, Registrations::Team.last)))
        end.to change(Registrations::Team, :count).by(1)
      end.to have_enqueued_job.exactly(:twice).and have_enqueued_job(ActionMailer::MailDeliveryJob).exactly(:twice)
    end
  end
end
