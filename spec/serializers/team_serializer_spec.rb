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

  describe ExtendedTeamSerializer do
    it 'adds scores' do
      score = create(:score, team:)
      group_score = create(:group_score, team:)
      competition_name = '01.05.2017 - Charlottenthal, D-Cup (Erster Lauf)'
      expect(serializer_json(described_class, team)).to eq base_hash.merge(
        fs_scores: [],
        gs_scores: [],
        la_scores: [{ id: group_score.id, competition: competition_name, competition_id: score.competition_id,
                      team_number: 1, second_time: '22,87' }],
        single_scores: [{ id: score.id, competition: competition_name, competition_id: score.competition_id,
                          team_number: 1, second_time: '19,76' }],
      )
    end
  end

  describe SuggestionTeamSerializer do
    it 'serializes team suggestion' do
      expect(serializer_json(described_class, team)).to eq(id: team.id, name: 'FF Warin', shortcut: 'Warin')
    end
  end

  describe TeamSpellingSerializer do
    it 'serializes team spelling' do
      expect(api_json(create(:team_spelling, team:))).to eq(team_id: team.id, name: 'FF Warino', shortcut: 'Warino')
    end
  end

  describe TeamMemberSerializer do
    it 'serializes team member' do
      score = create(:score, team:)
      expect(api_json(TeamMember.first)).to eq(person_id: score.person_id, team_id: team.id)
    end
  end
end
