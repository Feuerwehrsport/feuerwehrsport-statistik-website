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

  describe 'GET index' do
    before { team }

    it 'returns teams' do
      get '/api/teams'
      expect_json_response
      expect(json_body[:teams].first).to eq team_attributes
    end
  end
end
