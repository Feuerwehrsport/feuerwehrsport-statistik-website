# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Backend::Series::Participations', login: :admin do
  let!(:participation) { create(:series_person_participation) }
  let!(:team_participation) { create(:series_team_participation) }
  let(:round_path) { "/backend/series/rounds/#{participation.cup.round.id}" }

  describe 'person participations' do
    it 'shows the new form with preselected assessment' do
      get '/backend/series/person_participations/new',
          params: { cup_id: participation.cup_id, person_assessment_id: participation.person_assessment_id }
      expect(response).to be_successful
      expect(response.body).to include('Eintrag hinzufügen', 'association-select')
    end

    it 'creates an entry with change log' do
      expect do
        post '/backend/series/person_participations', params: { series_person_participation: {
          cup_id: participation.cup_id, person_assessment_id: participation.person_assessment_id,
          person_id: create(:person, first_name: 'Neu').id, rank: 5, points: 3, time: 2000
        } }
      end.to change(Series::PersonParticipation, :count).by(1)
      expect(response).to redirect_to(round_path)
      expect(ChangeLog.last).to have_attributes(action: 'create-series-personparticipation', admin_user: login_user)
    end

    it 'shows errors' do
      patch "/backend/series/person_participations/#{participation.id}",
            params: { series_person_participation: { rank: '' } }
      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'moves up and down' do
      patch "/backend/series/person_participations/#{participation.id}/move", params: { direction: 'up' }
      expect(participation.reload).to have_attributes(rank: 1, points: 16)
      patch "/backend/series/person_participations/#{participation.id}/move", params: { direction: 'up' }
      expect(participation.reload).to have_attributes(rank: 1, points: 17)
      patch "/backend/series/person_participations/#{participation.id}/move", params: { direction: 'down' }
      expect(participation.reload).to have_attributes(rank: 2, points: 16)
      expect(response).to redirect_to(round_path)
    end

    it 'deletes an entry' do
      expect { delete "/backend/series/person_participations/#{participation.id}" }
        .to change(Series::PersonParticipation, :count).by(-1)
      expect(ChangeLog.last).to have_attributes(action: 'destroy-series-personparticipation')
    end
  end

  describe 'team participations' do
    it 'shows the edit form and updates' do
      get "/backend/series/team_participations/#{team_participation.id}/edit"
      expect(response.body).to include('Eintrag bearbeiten', 'Platz höher')

      patch "/backend/series/team_participations/#{team_participation.id}",
            params: { series_team_participation: { team_number: 2, team_gender: 0 } }
      expect(team_participation.reload).to have_attributes(team_number: 2, team_gender: 0)
    end
  end

  context 'when sub admin without series', login: :sub_admin do
    it 'is denied' do
      get "/backend/series/team_participations/#{team_participation.id}/edit"
      expect(response).to redirect_to('/')
    end
  end
end
