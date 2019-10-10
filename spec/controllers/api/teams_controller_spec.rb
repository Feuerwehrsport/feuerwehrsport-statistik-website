require 'rails_helper'

RSpec.describe API::TeamsController, type: :controller do
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
    }
  end

  describe 'POST create' do
    subject { -> { post :create, params: { team: { name: 'Mannschaft1', shortcut: 'Mann1', status: 'fire_station' } } } }

    it 'creates new team', login: :api do
      expect do
        subject.call
        expect_api_login_response(created_id: Team.last.id)
      end.to change(Team, :count).by(1)
      expect_change_log(after: { name: 'Mannschaft1' }, log: 'create-team')
    end
  end

  describe 'GET show' do
    it 'returns team' do
      get :show, params: { id: team.id }
      expect(json_body[:team]).to eq team_attributes
    end

    context 'when extended' do
      let!(:score) { create(:score, team: team) }
      let!(:group_score) { create(:group_score, team: team) }

      it 'returns team' do
        get :show, params: { id: team.id, extended: 1 }
        expect(json_body[:team]).to include(team_attributes)
        expect(json_body[:team][:single_scores]).to have(1).items
        expect(json_body[:team][:la_scores]).to have(1).items
        expect(json_body[:team][:fs_scores]).to have(0).items
        expect(json_body[:team][:gs_scores]).to have(0).items
      end
    end
  end

  describe 'GET index' do
    before { team }

    it 'returns teams' do
      get :index
      expect_json_response
      expect(json_body[:teams].first).to eq team_attributes
    end
  end

  describe 'PUT update' do
    subject { -> { put :update, params: { id: team.id, team: changed_attributes } } }

    let(:changed_attributes) { { latitude: '12.0', longitude: '34.0' } }

    it 'updates team', login: :api do
      subject.call
      expect(json_body[:team]).to eq(team_attributes.merge(changed_attributes))
    end

    context 'when updating extended attributes' do
      let(:changed_attributes) { { name: 'FF Hanswurst', shortcut: 'Hanswurst', status: 'team' } }

      context 'when user have not enough permissions', login: :api do
        it 'failes to update' do
          subject.call
          expect(json_body[:team]).to eq(team_attributes)
        end
      end

      it 'success', login: :sub_admin do
        subject.call
        expect(json_body[:team]).to eq(team_attributes.merge(changed_attributes))
        expect_change_log(before: { name: 'FF Warin' }, after: { name: 'FF Hanswurst' }, log: 'update-team')
      end
    end
  end

  describe 'POST merge' do
    subject { -> { put :merge, params: { id: bad_team.id, correct_team_id: team.id, always: 1 } } }

    let(:bad_team) { create(:team, :mv) }

    it 'merge two teams', login: :sub_admin do
      expect_any_instance_of(Team).to receive(:merge_to).and_call_original
      expect do
        subject.call
      end.to change(TeamSpelling, :count).by(1)

      expect_json_response
      expect(json_body[:team]).to eq(team_attributes)
    end

    it 'creates entity_merge', login: :sub_admin do
      expect do
        subject.call
      end.to change(EntityMerge, :count).by(1)
    end

    it_behaves_like 'api user get permission error'
  end
end
