# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::Teams' do
  let(:team) { create(:team) }
  let(:team_attributes) do
    {
      id: team.id,
      latitude: '52.12',
      longitude: '14.45',
      name: 'FF Warin',
      shortcut: 'Warin',
      state: 'MV',
      status: 'fire_station',
      tile_path: nil,
      best_scores: {},
    }
  end

  describe 'POST create' do
    let(:r) { -> { post '/api/teams', params: } }
    let(:params) { { team: { name: 'Mannschaft1', shortcut: 'Mann1', status: 'fire_station' } } }

    it 'creates new team', login: :api do
      expect do
        r.call
        expect_api_login_response(created_id: Team.last.id)
      end.to change(Team, :count).by(1)
      expect_change_log(after: { name: 'Mannschaft1' }, log: 'create-team')
    end
  end

  describe 'GET show' do
    it 'returns team' do
      get "/api/teams/#{team.id}"
      expect(json_body[:team]).to eq team_attributes
    end

    context 'when extended' do
      let!(:score) { create(:score, team:) }
      let!(:group_score) { create(:group_score, team:) }

      it 'returns team' do
        get "/api/teams/#{team.id}", params: { extended: 1 }
        expect(json_body[:team]).to include(team_attributes)
        expect(json_body[:team][:single_scores].count).to eq 1
        expect(json_body[:team][:la_scores].count).to eq 1
        expect(json_body[:team][:fs_scores].count).to eq 0
        expect(json_body[:team][:gs_scores].count).to eq 0
      end
    end
  end

  describe 'GET index' do
    before { team }

    it 'returns teams' do
      get '/api/teams'
      expect_json_response
      expect(json_body[:teams].first).to eq team_attributes
    end
  end

  describe 'PUT update' do
    let(:r) { -> { put "/api/teams/#{team.id}", params: { team: changed_attributes } } }

    let(:changed_attributes) { { latitude: '12.0', longitude: '34.0' } }

    it 'updates team', login: :api do
      r.call
      expect(json_body[:team]).to eq(team_attributes.merge(changed_attributes))
    end

    context 'when updating extended attributes' do
      let(:changed_attributes) { { name: 'FF Hanswurst', shortcut: 'Hanswurst', status: 'team' } }

      context 'when user have not enough permissions', login: :api do
        it 'failes to update' do
          r.call
          expect(json_body[:team]).to eq(team_attributes)
        end
      end

      it 'success', login: :sub_admin do
        r.call
        expect(json_body[:team]).to eq(team_attributes.merge(changed_attributes))
        expect_change_log(before: { name: 'FF Warin' }, after: { name: 'FF Hanswurst' }, log: 'update-team')
      end
    end
  end

  describe 'POST merge' do
    let(:r) { -> { post "/api/teams/#{bad_team.id}/merge", params: { correct_team_id: team.id, always: 1 } } }

    let(:bad_team) { create(:team, :mv) }

    it 'merge two teams', login: :sub_admin do
      expect_any_instance_of(Team).to receive(:merge_to).and_call_original
      expect do
        r.call
      end.to change(TeamSpelling, :count).by(1)

      expect_json_response
      expect(json_body[:team]).to eq(team_attributes)
    end

    it 'creates entity_merge', login: :sub_admin do
      expect do
        r.call
      end.to change(EntityMerge, :count).by(1)
    end

    it_behaves_like 'api user get permission error'
  end
end
