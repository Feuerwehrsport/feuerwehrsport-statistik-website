# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Backend::Repairs::TeamScoreMovesController, type: :controller, login: :sub_admin do
  describe 'GET new' do
    it 'shows new form' do
      get :new
      expect(response).to be_successful
    end
  end

  describe 'POST create' do
    let!(:team1) { create(:team) }
    let!(:team2) { create(:team) }

    it 'renders create view' do
      post :create, params: { repairs_team_score_move: { source_team_id: team1.id, destination_team_id: team2.id } }
      expect(response).to render_template :create
    end
  end
end
