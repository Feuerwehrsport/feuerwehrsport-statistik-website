# frozen_string_literal: true

require 'rails_helper'
require_relative 'serializer_helper'

RSpec.describe GroupScoreSerializer do
  include SerializerSpecHelper

  let(:group_score) { create(:group_score, :double) }
  let(:person) { create(:person) }

  def empty_positions(except = [])
    (1..7).each_with_object({}) do |position, hash|
      next if position.in?(except)

      hash[:"person_#{position}"] = nil
      hash[:"person_#{position}_first_name"] = nil
      hash[:"person_#{position}_last_name"] = nil
    end
  end

  it 'serializes group score with similar scores and participations' do
    create(:person_participation, group_score:, person:, position: 2)
    other = GroupScore.where.not(id: group_score.id).first

    json = api_json(group_score)
    expect(json.except(:similar_scores)).to eq(
      id: group_score.id, team_id: group_score.team_id, team_number: 1, gender: 'male', time: 2287,
      group_score_category_id: group_score.group_score_category_id, run: nil, discipline: 'la',
      second_time: '22,87', translated_discipline_name: 'Löschangriff nass'
    )
    expect(json[:similar_scores]).to eq [
      { id: group_score.id, time: 2287, second_time: '22,87',
        person_2: person.id, person_2_first_name: 'Alfred', person_2_last_name: 'Meier' }.merge(empty_positions([2])),
      { id: other.id, time: 2345, second_time: '23,45' }.merge(empty_positions),
    ]
  end

  describe GroupScoreCategorySerializer do
    it 'serializes category' do
      category = group_score.group_score_category
      expect(api_json(category)).to eq(
        id: category.id, group_score_type: 'WKO', competition: '01.05.2017 - Charlottenthal, D-Cup (Erster Lauf)',
        name: 'default'
      )
    end
  end

  describe GroupScoreTypeSerializer do
    it 'serializes type' do
      type = group_score.group_score_category.group_score_type
      expect(api_json(type)).to eq(id: type.id, discipline: 'la', name: 'WKO', regular: true)
    end
  end
end
