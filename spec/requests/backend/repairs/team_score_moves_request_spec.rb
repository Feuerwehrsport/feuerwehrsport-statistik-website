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
    end
  end
end
