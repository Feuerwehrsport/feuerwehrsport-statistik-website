# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Backend::Repairs::TeamScoreMoves', login: :sub_admin do
  describe 'GET new' do
    it 'shows new form' do
      get '/backend/repairs/team_score_move/new'
      expect(response).to be_successful
    end
  end

  describe 'POST create' do
    let!(:team1) { create(:team) }
    let!(:team2) { create(:team) }

    it 'renders create view' do
      post '/backend/repairs/team_score_move',
           params: { repairs_team_score_move: { source_team_id: team1.id, destination_team_id: team2.id } }
      expect(response).to be_successful
      query = { repairs_team_score_move: { destination_team_id: team2.id, source_team_id: team1.id } }.to_query
      back_url = "/backend/repairs/team_score_move/new?#{query}"
      expect(response.body).to include(ERB::Util.html_escape(back_url))
    end
  end

  describe 'POST execute' do
    let!(:team1) { create(:team) }
    let!(:team2) { create(:team, name: 'FF Ziel', shortcut: 'Ziel') }
    let!(:score) { create(:score, team: team1) }
    let!(:other_score) { create(:score, team: team1) }
    let!(:group_score) { create(:group_score, team: team1) }
    let!(:foreign_score) { create(:score, team: team2) }

    it 'shows the scores of the source team' do
      post '/backend/repairs/team_score_move',
           params: { repairs_team_score_move: { source_team_id: team1.id, destination_team_id: team2.id } }
      expect(response.body).to include(%(name="score_ids[]" id="move-score_ids-#{score.id}"),
                                       %(name="group_score_ids[]"), 'Löschangriff')
    end

    it 'moves only selected scores of the source team' do
      post '/backend/repairs/team_score_move/execute',
           params: { source_team_id: team1.id, destination_team_id: team2.id,
                     score_ids: [score.id, foreign_score.id], group_score_ids: [group_score.id] }
      expect(response).to redirect_to('/backend')
      expect(flash[:notice]).to eq '2 Zeiten von FF Warin nach FF Ziel verschoben.'
      expect(score.reload.team).to eq team2
      expect(group_score.reload.team).to eq team2
      expect(other_score.reload.team).to eq team1
      expect(ChangeLog.pluck(:action)).to contain_exactly('update-score:team', 'update-group-score:team')
    end

    it 'goes back without selection' do
      post '/backend/repairs/team_score_move/execute',
           params: { source_team_id: team1.id, destination_team_id: team2.id }
      expect(response).to redirect_to(%r{/backend/repairs/team_score_move/new})
      expect(flash[:alert]).to eq 'Keine Zeiten ausgewählt.'
    end
  end
end
