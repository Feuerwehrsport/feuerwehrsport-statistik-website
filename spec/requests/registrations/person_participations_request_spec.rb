# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Registrations::PersonParticipations', login: :user do
  let(:competition) { create(:registrations_competition) }
  let(:band) { create(:registrations_band, competition:) }
  let(:person) { create(:registrations_person, band:) }
  let(:assessment) { create(:registrations_assessment, band:) }

  describe 'GET edit' do
    it 'renders form' do
      get "/registrations/bands/#{band.id}/person_participations/#{person.id}/edit"
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
      patch "/registrations/bands/#{band.id}/person_participations/#{person.id}",
            params: { registrations_person: update_params }
      expect(response).to redirect_to(registrations_competition_path(competition))
      expect(person.reload.assessments).to eq [assessment]
    end

    context 'when person has team' do
      let(:team) { create(:registrations_team, band:) }
      let(:person) { create(:registrations_person, team:, band:) }

      it 'redirect to team page' do
        patch "/registrations/bands/#{band.id}/person_participations/#{person.id}",
              params: { registrations_person: update_params }
        expect(response).to redirect_to(registrations_band_team_path(band, team))
      end
    end
  end
end
