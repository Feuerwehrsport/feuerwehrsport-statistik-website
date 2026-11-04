# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Backend::UncheckedTeams', login: :sub_admin do
  let!(:unchecked_team) { create(:team, checked_at: nil) }
  let!(:checked_team) { create(:team, :mv, checked_at: Time.current) }

  describe 'GET index' do
    it 'lists only unchecked teams' do
      get '/backend/unchecked_teams'
      expect(response).to be_successful
      expect(controller.send(:collection).to_a).to eq [UncheckedTeam.find(unchecked_team.id)]
    end
  end

  describe 'GET show' do
    let!(:similar_team) { create(:team, name: 'FF Warim', shortcut: 'Warim', checked_at: Time.current) }

    it 'shows team with similar teams' do
      get "/backend/unchecked_teams/#{unchecked_team.id}"
      expect(response).to be_successful
      expect(response.body).to include('Ähnlich geschriebene Mannschaften')
      expect(response.body).to include(%(data-correct-id="#{similar_team.id}"))
    end

    it 'does not find checked teams' do
      get "/backend/unchecked_teams/#{checked_team.id}"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'PUT update' do
    it 'redirects to index after marking as checked' do
      put "/backend/unchecked_teams/#{unchecked_team.id}", params: { unchecked_team: { checked_at: Time.current } }
      expect(response).to redirect_to(action: :index)
      expect(unchecked_team.reload.checked_at).to be_present
    end

    it 'redirects to show when not marked as checked' do
      put "/backend/unchecked_teams/#{unchecked_team.id}", params: { unchecked_team: { name: 'FF Warin 2' } }
      expect(response).to redirect_to(action: :show, id: unchecked_team.id)
      expect(unchecked_team.reload.name).to eq 'FF Warin 2'
    end
  end

  context 'when logged in as simple user', login: :user do
    it 'denies destroy' do
      expect do
        delete "/backend/unchecked_teams/#{unchecked_team.id}"
      end.not_to change(Team, :count)
      expect(response).to redirect_to('/')
    end

    # NOTE: Ability gives every user (and API user) :update on Team, so also UncheckedTeam can be updated
    it 'allows update (Team update ability)' do
      put "/backend/unchecked_teams/#{unchecked_team.id}", params: { unchecked_team: { checked_at: Time.current } }
      expect(response).to redirect_to(action: :index)
      expect(unchecked_team.reload.checked_at).to be_present
    end
  end
end
