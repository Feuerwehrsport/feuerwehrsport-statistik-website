# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Series::AssessmentConfig do
  let(:attributes) do
    {
      key: 'female',
      disciplines: ['hb'],
      name: 'Frauen',
      calc_participations_count: 2,
      ranking_logic: %w[points],
    }
  end
  let(:config) { described_class.new(attributes) }

  describe 'initialization' do
    it 'ignores unknown attributes and accepts string keys' do
      config = described_class.new('key' => 'male', 'unknown' => 1, :name => 'Männer')
      expect(config.key).to eq 'male'
      expect(config.name).to eq 'Männer'
    end

    it 'sets defaults' do
      config = described_class.new
      expect(config.disciplines).to eq []
      expect(config.points_for_rank).to eq []
      expect(config.ranking_logic).to eq []
      expect(config.honor_ranking_logic).to eq []
      expect(config.show_columns).to eq %w[participation_count points]
      expect(config.min_participations_count).to eq 1
      expect(config.honor_rank).to eq 3
      expect(config.penalty_points).to be_nil
    end

    it 'replaces explicit nil arrays with empty arrays' do
      config = described_class.new(disciplines: nil, points_for_rank: nil, ranking_logic: nil)
      expect(config.disciplines).to eq []
      expect(config.points_for_rank).to eq []
      expect(config.ranking_logic).to eq []
    end
  end

  describe 'validations' do
    it 'is valid with minimal attributes' do
      expect(config).to be_valid
    end

    it 'requires key, name, disciplines and ranking_logic' do
      config = described_class.new(calc_participations_count: 1)
      expect(config).not_to be_valid
      expect(config.errors.attribute_names).to include(:key, :name, :disciplines, :ranking_logic)
    end

    it 'rejects unknown ranking logic and show columns' do
      config = described_class.new(attributes.merge(ranking_logic: %w[foo], honor_ranking_logic: %w[bar],
                                                    show_columns: %w[baz]))
      expect(config).not_to be_valid
      expect(config.errors.attribute_names).to include(:ranking_logic, :honor_ranking_logic, :show_columns)
    end

    it 'requires positive integers for counts' do
      config = described_class.new(attributes.merge(calc_participations_count: 0, min_participations_count: 0,
                                                    honor_rank: 0))
      expect(config).not_to be_valid
      expect(config.errors.attribute_names).to include(:calc_participations_count, :min_participations_count,
                                                       :honor_rank)
    end

    it 'requires integer points' do
      config = described_class.new(attributes.merge(points_for_rank: ['a']))
      expect(config).not_to be_valid
      expect(config.errors.attribute_names).to include(:points_for_rank)
    end
  end

  describe 'config helpers' do
    let(:attributes) do
      super().merge(show_columns: %w[points best_time], ranking_logic: %w[points sum_time],
                    honor_ranking_logic: %w[best_rank])
    end

    it 'maps keys to configuration hashes' do
      expect(config.show_columns_config).to eq [
        { name: 'Punkte', method: :points },
        { name: 'Bestzeit', method: :second_best_time },
      ]
      expect(config.ranking_logic_config.pluck(:name)).to eq ['Punkte (mehr zuerst)',
                                                              'Summe der Zeiten (kleiner zuerst)']
      expect(config.honor_ranking_logic_config.pluck(:name)).to eq ['Beste Platzierung (kleiner zuerst)']
    end
  end

  describe '.find_by_round_key' do
    let(:round) { create(:series_round) }

    it 'returns config of round' do
      team_config = described_class.find_by_round_key("#{round.id}-male", :team)
      expect(team_config.name).to eq 'Männer'
      expect(team_config.round).to eq round
      expect(team_config.entity_key).to eq :team

      person_config = described_class.find_by_round_key("#{round.id}-female", :person)
      expect(person_config.disciplines).to eq ['hb']
      expect(person_config.entity_key).to eq :person
    end

    it 'returns nil for invalid keys' do
      expect(described_class.find_by_round_key(nil, :team)).to be_nil
      expect(described_class.find_by_round_key('', :team)).to be_nil
      expect(described_class.find_by_round_key('female', :team)).to be_nil
      expect(described_class.find_by_round_key("#{round.id}-unknown", :team)).to be_nil
    end
  end

  describe '#sort' do
    def entity(**values)
      instance_double(Series::Person, **values)
    end

    def compare(logic, first, second)
      described_class.new(attributes).sort(first, second, logic_array: [logic])
    end

    it 'sorts by rank (smaller first, nil last)' do
      expect(compare('rank', entity(rank: 1), entity(rank: 2))).to eq(-1)
      expect(compare('rank', entity(rank: nil), entity(rank: 2))).to eq 1
    end

    it 'sorts by participation count (more first)' do
      expect(compare('participation_count', entity(ordered_participations: [1, 2]),
                     entity(ordered_participations: [1]))).to eq(-1)
    end

    it 'sorts by valid participation count (more first)' do
      expect(compare('valid_participation_count', entity(valid_participations: [1]),
                     entity(valid_participations: [1, 2]))).to eq 1
    end

    it 'sorts by points' do
      expect(compare('points', entity(points: 10), entity(points: 5))).to eq(-1)
      expect(compare('points_reverse', entity(points: 10), entity(points: 5))).to eq 1
      expect(compare('all_points', entity(all_points: 3), entity(all_points: 5))).to eq 1
    end

    it 'sorts by times (smaller first)' do
      expect(compare('best_time', entity(best_time_without_nil: 1900),
                     entity(best_time_without_nil: 2000))).to eq(-1)
      expect(compare('sum_time', entity(sum_time: 5000), entity(sum_time: 4000))).to eq 1
    end

    it 'sorts by best rank and best rank count' do
      expect(compare('best_rank', entity(best_rank: 1), entity(best_rank: 2))).to eq(-1)
      expect(compare('best_rank_count', entity(best_rank_count: 1), entity(best_rank_count: 3))).to eq 1
    end

    it 'uses next logic if first logic is equal' do
      config = described_class.new(attributes.merge(ranking_logic: %w[points best_time]))
      first = entity(points: 10, best_time_without_nil: 2000)
      second = entity(points: 10, best_time_without_nil: 1900)
      expect(config.sort(first, second)).to eq 1
      expect(config.sort(first, first)).to eq 0
    end

    it 'puts rank before all other logics with with_rank' do
      first = entity(rank: 2, points: 10)
      second = entity(rank: 1, points: 5)
      expect(config.sort(first, second)).to eq(-1)
      expect(config.sort(first, second, with_rank: true)).to eq 1
    end
  end
end
