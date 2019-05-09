require 'rails_helper'

RSpec.describe Registrations::PersonParticipationsController, type: :controller, login: :user do
  let(:competition) { create(:registrations_competition) }
  let(:person) { create(:registrations_person, competition: competition) }
  let(:assessment) { create(:registrations_assessment, competition: competition) }

  describe 'GET edit' do
    it 'renders form' do
      get :edit, competition_id: competition.id, id: person.id
      expect(response).to be_success
    end
  end

  describe 'PATCH update' do
    it 'updates' do
      patch :update, competition_id: competition.id, id: person.id, registrations_person: {
        person_assessment_participations_attributes: {
          '0' => {
            _destroy: 0,
            assessment_id: assessment.id,
            assessment_type: :single_competitor,
            group_competitor_order: 0,
            single_competitor_order: 0,
          },
        },
      }
      expect(response).to redirect_to(registrations_competition_path(competition))
      expect(person.reload.assessments).to eq [assessment]
    end

    context 'when person has team' do
      let(:team) { create(:registrations_team, competition: competition) }
      let(:person) { create(:registrations_person, team: team, competition: competition) }

      it 'redirect to team page' do
        patch :update, competition_id: competition.id, id: person.id, registrations_person: {}
        expect(response).to redirect_to(registrations_competition_team_path(competition, team))
      end
    end
  end
end
