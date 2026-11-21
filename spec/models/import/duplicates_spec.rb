# frozen_string_literal: true

require 'rails_helper'

describe Import::Duplicates do
  let(:competition) { create(:competition) }

  context 'with single disciplines' do
    let(:single_discipline) { create(:single_discipline, :hb_male) }
    let(:person) { create(:person) }
    let(:duplicates) { described_class.new(competition_id: competition.id, discipline: 'hb', gender: 'male') }

    before { create(:score, competition:, person:, single_discipline:, time: 1922) }

    it 'finds the same person with the same time' do
      expect(duplicates.times(person_id: person.id.to_s, times: %w[1922 1899])).to eq [1922]
      expect(duplicates.times(person_id: person.id, times: [1899])).to eq []
      expect(duplicates.times(person_id: nil, times: [1922])).to eq []
      expect(duplicates.any?([{ person_id: person.id, times: [1922] }])).to be true
    end

    it 'ignores other competitions' do
      other = described_class.new(competition_id: create(:competition).id, discipline: 'hb', gender: 'male')
      expect(other.times(person_id: person.id, times: [1922])).to eq []
    end
  end

  context 'with group disciplines' do
    let(:team) { create(:team) }
    let(:category) { create(:group_score_category, competition:) }
    let(:duplicates) { described_class.new(competition_id: competition.id, discipline: 'la', gender: 'female') }

    before { GroupScore.create!(group_score_category: category, team:, team_number: 1, gender: :female, time: 2287) }

    it 'finds the same team, number and gender with the same time' do
      expect(duplicates.times(team_id: team.id, team_number: '1', times: [2287, 2400])).to eq [2287]
      expect(duplicates.times(team_id: team.id, team_number: 2, times: [2287])).to eq []
      male = described_class.new(competition_id: competition.id, discipline: 'la', gender: 'male')
      expect(male.times(team_id: team.id, team_number: 1, times: [2287])).to eq []
    end
  end
end
