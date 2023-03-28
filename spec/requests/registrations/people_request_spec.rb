# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Registrations::People', login: :user do
  let(:competition) { create(:registrations_competition) }
  let(:band) { create(:registrations_band, competition:) }
  let(:team) { create(:registrations_team, band:) }
  let(:person) { create(:registrations_person, band:) }

  describe 'GET edit' do
    it 'renders form' do
      get "/registrations/bands/#{band.id}/people/#{person.id}/edit"
      expect(response).to be_successful
    end
  end

  describe 'PATCH update' do
    let!(:assessment) { create(:registrations_assessment, :la, band:) }

    it 'updates' do
      patch "/registrations/bands/#{band.id}/people/#{person.id}", params: {
        registrations_person: { last_name: 'new-name' },
      }
      expect(response).to redirect_to registrations_competition_path(competition)
      expect(person.reload.last_name).to eq 'new-name'
    end
  end

  describe 'DELETE destroy' do
    it 'destroys' do
      person # to load instance
      expect do
        delete "/registrations/bands/#{band.id}/people/#{person.id}"
        expect(response).to redirect_to registrations_competition_path(competition)
      end.to change(Registrations::Person, :count).by(-1)
    end

    context 'when person has a team' do
      let(:person) { create(:registrations_person, team:, band:) }

      it 'redirects to team page' do
        delete "/registrations/bands/#{band.id}/people/#{person.id}"
        expect(response).to redirect_to registrations_band_team_path(band, team)
      end
    end
  end
end
