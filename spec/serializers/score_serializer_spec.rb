# frozen_string_literal: true

require 'rails_helper'
require_relative 'serializer_helper'

RSpec.describe ScoreSerializer do
  include SerializerSpecHelper

  let(:score) { create(:score) }

  it 'serializes score with similar scores of same person and competition' do
    hl = create(:score, :hl, person: score.person, competition: score.competition, time: 1800)
    create(:score, person: create(:person, first_name: 'Other'), competition: score.competition)

    expect(api_json(score)).to eq(
      id: score.id, team_id: score.team_id, team_number: 1, time: 1976, single_discipline_id: 3,
      second_time: '19,76', translated_discipline_name: 'Hindernisbahn',
      similar_scores: [
        { id: score.id, time: 1976, second_time: '19,76', discipline_key: 'hb',
          translated_discipline_name: 'Hindernisbahn', team_id: score.team_id, team_number: 1 },
        { id: hl.id, time: 1800, second_time: '18,00', discipline_key: 'hl',
          translated_discipline_name: 'Hakenleitersteigen', team_id: score.team_id, team_number: 1 },
      ],
      person: 'Alfred Meier', discipline_key: 'hb'
    )
  end

  describe ScoreTypeSerializer do
    it 'serializes score type' do
      score_type = create(:score_type)
      expect(api_json(score_type)).to eq(id: score_type.id, people: 10, run: 8, score: 6)
    end
  end
end
