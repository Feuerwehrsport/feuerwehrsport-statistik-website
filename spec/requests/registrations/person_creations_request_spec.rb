# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Registrations::PersonCreations', login: :user do
  let(:band) { create(:registrations_band) }
  let(:team) { create(:registrations_team, band:) }
  let(:person_attrs) { { first_name: 'Alfred', last_name: 'Meier', gender: :male } }

  describe 'GET new' do
    it 'redirects' do
      get "/registrations/bands/#{band.id}/person_creation/new"
      expect(response).to be_successful
    end
  end

  describe 'POST create' do
    it 'saves' do
      expect do
        expect do
          post "/registrations/bands/#{band.id}/person_creation",
               params: { registrations_person: person_attrs }
          expect(response).to redirect_to(registrations_competition_path(band.competition))
        end.to change(Registrations::Person, :count).by(1)
      end.to have_enqueued_job.exactly(:twice).and have_enqueued_job(ActionMailer::MailDeliveryJob).exactly(:twice)
    end

    context 'when team is set' do
      it 'saves and redirects to team' do
        expect do
          expect do
            post "/registrations/bands/#{band.id}/person_creation", params: {
              registrations_person: person_attrs, team_id: team.id
            }
            expect(response).to redirect_to(registrations_band_team_path(band, team))
          end.to change(Registrations::Person, :count).by(1)
        end.not_to have_enqueued_job
      end
    end
  end
end
