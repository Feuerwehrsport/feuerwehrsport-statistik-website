# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Registrations::PersonParticipationsController, login: :user do
  let(:competition) { create(:registrations_competition) }
  let(:person) { create(:registrations_person, competition: competition) }
  let(:assessment) { create(:registrations_assessment, competition: competition) }

  describe 'GET edit' do
    it 'renders form' do
      get :edit, params: { competition_id: competition.id, id: person.id }
      expect(response).to be_successful
    end
  end

  describe 'PATCH update' do
    let(:update_params) do
      { person_assessment_participations_attributes: {
        '0' => {
          _destroy: 0,
          assessment_id: assessment.id,
          assessment_type: :single_competitor,
          group_competitor_order: 0,
          single_competitor_order: 0,
        },
      } }
    end

    it 'updates' do
      patch :update, params: { competition_id: competition.id, id: person.id, registrations_person: update_params }
      expect(response).to redirect_to(registrations_competition_path(competition))
      expect(person.reload.assessments).to eq [assessment]
    end

    context 'when person has team' do
      let(:team) { create(:registrations_team, competition: competition) }
      let(:person) { create(:registrations_person, team: team, competition: competition) }

      it 'redirect to team page' do
        patch :update, params: { competition_id: competition.id, id: person.id, registrations_person: update_params }
        expect(response).to redirect_to(registrations_competition_team_path(competition, team))
      end
    end
  end
end
