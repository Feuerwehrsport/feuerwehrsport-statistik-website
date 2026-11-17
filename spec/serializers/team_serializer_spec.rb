# frozen_string_literal: true

require 'rails_helper'
require_relative 'serializer_helper'

RSpec.describe TeamSerializer do
  include SerializerSpecHelper

  let(:team) { create(:team) }
  let(:base_hash) do
    { id: team.id, name: 'FF Warin', shortcut: 'Warin', status: 'fire_station', latitude: '52.12',
      longitude: '14.45', state: 'MV', tile_path: nil, best_scores: {} }
  end

  it 'serializes team' do
    expect(api_json(team)).to eq base_hash
  end

  describe TeamSpellingSerializer do
    it 'serializes team spelling' do
      expect(api_json(create(:team_spelling, team:))).to eq(team_id: team.id, name: 'FF Warino', shortcut: 'Warino')
    end
  end

  describe TeamMemberSerializer do
    it 'serializes team member' do
      score = create(:score, team:)
      expect(api_json(TeamMember.take)).to eq(person_id: score.person_id, team_id: team.id)
    end
  end
end
