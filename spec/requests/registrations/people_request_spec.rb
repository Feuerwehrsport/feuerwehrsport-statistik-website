# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Registrations::People', login: :user do
  let(:competition) { create(:registrations_competition, team_tags: 'Sport') }
  let(:team) { create(:registrations_team, competition:) }
  let(:person) { create(:registrations_person, competition:) }

  describe 'GET edit' do
    it 'renders form' do
      get "/registrations/competitions/#{competition.id}/people/#{person.id}/edit"
      expect(response).to be_successful
    end
  end

  describe 'PATCH update' do
    let!(:assessment) { create(:registrations_assessment, :la, competition:) }

    it 'updates' do
      patch "/registrations/competitions/#{competition.id}/people/#{person.id}", params: {
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
        delete "/registrations/competitions/#{competition.id}/people/#{person.id}"
        expect(response).to redirect_to registrations_competition_path(competition)
      end.to change(Registrations::Person, :count).by(-1)
    end

    context 'when person has a team' do
      let(:person) { create(:registrations_person, team:, competition:) }

      it 'redirects to team page' do
        delete "/registrations/competitions/#{competition.id}/people/#{person.id}"
        expect(response).to redirect_to registrations_competition_team_path(competition, team)
      end
    end
  end
end
