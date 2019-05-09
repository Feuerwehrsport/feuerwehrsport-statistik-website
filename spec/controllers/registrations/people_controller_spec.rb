require 'rails_helper'

RSpec.describe Registrations::PeopleController, type: :controller, login: :user do
  let(:competition) { create(:registrations_competition, team_tags: 'Sport') }
  let(:team) { create(:registrations_team, competition: competition) }
  let(:person) { create(:registrations_person, competition: competition) }

  describe 'GET edit' do
    it 'renders form' do
      get :edit, id: person.id, competition_id: competition.id
      expect(response).to be_success
    end
  end

  describe 'PATCH update' do
    let!(:assessment) { create(:registrations_assessment, :la, competition: competition) }

    it 'updates' do
      patch :update, id: person.id, competition_id: competition.id, registrations_person: { last_name: 'new-name' }
      expect(response).to redirect_to registrations_competition_path(competition)
      expect(person.reload.last_name).to eq 'new-name'
    end
  end

  describe 'DELETE destroy' do
    it 'destroys' do
      person # to load instance
      expect do
        delete :destroy, id: person.id, competition_id: competition.id
        expect(response).to redirect_to registrations_competition_path(competition)
      end.to change(Registrations::Person, :count).by(-1)
    end

    context 'when person has a team' do
      let(:person) { create(:registrations_person, team: team, competition: competition) }

      it 'redirects to team page' do
        delete :destroy, id: person.id, competition_id: competition.id
        expect(response).to redirect_to registrations_competition_team_path(competition, team)
      end
    end
  end
end
