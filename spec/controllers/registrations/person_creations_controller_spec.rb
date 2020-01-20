require 'rails_helper'

RSpec.describe Registrations::PersonCreationsController, type: :controller, login: :user do
  let(:competition) { create(:registrations_competition) }
  let(:team) { create(:registrations_team) }
  let(:person_attrs) { { first_name: 'Alfred', last_name: 'Meier', gender: :male } }

  describe 'GET new' do
    it 'redirects' do
      get :new, params: { competition_id: competition.id }
      expect(response).to be_successful
    end
  end

  describe 'POST create' do
    it 'saves' do
      expect do
        expect do
          post :create, params: { competition_id: competition.id, registrations_person: person_attrs }
          expect(response).to redirect_to(registrations_competition_path(competition))
        end.to change(Registrations::Person, :count).by(1)
      end.to change(ActionMailer::Base.deliveries, :count).by(2)
    end

    context 'when team is set' do
      it 'saves and redirects to team' do
        expect do
          expect do
            post :create, params: {
              competition_id: competition.id, registrations_person: person_attrs, team_id: team.id
            }
            expect(response).to redirect_to(registrations_competition_team_path(competition, team))
          end.to change(Registrations::Person, :count).by(1)
        end.to change(ActionMailer::Base.deliveries, :count).by(0)
      end
    end
  end
end
