# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Series::Person do
  let(:config) do
    Series::AssessmentConfig.new(key: 'female', disciplines: ['hb'], calc_participations_count: 2,
                                 ranking_logic: %w[points best_time])
  end
  let(:cup1) { participation(1, time: 1900, points: 10, rank: 3) }
  let(:cup2) { participation(2, time: 1800, points: 15, rank: 1) }
  let(:cup3) { participation(3, time: 2000, points: 12, rank: 2, points_correction: -4) }
  let(:person) { described_class.new(config:, person: build_stubbed(:person)) }

  def participation(cup_id, time:, points:, rank: 1, points_correction: nil)
    Series::PersonParticipation.new(cup_id:, time:, points:, rank:, points_correction:)
  end

  describe 'new entity' do
    it 'starts with rank 0 and no participations' do
      expect(person.rank).to eq 0
      expect(person.count).to eq 0
      expect(person.points_for_cup(build_stubbed(:series_cup, id: 1))).to eq 0
      expect(person.participation_for_cup(build_stubbed(:series_cup, id: 1))).to be_nil
    end

    it 'delegates person_id' do
      expect(person.person_id).to eq person.person.id
    end
  end

  context 'with three participations' do
    before do
      [cup1, cup2, cup3].each { |p| person.add_participation(p) }
    end

    it 'counts participations' do
      expect(person.count).to eq 3
      expect(person.participation_count).to eq 3
    end

    it 'returns participation and points per cup' do
      expect(person.participation_for_cup(build_stubbed(:series_cup, id: 2))).to eq cup2
      expect(person.points_for_cup(build_stubbed(:series_cup, id: 3))).to eq 8
      expect(person.participation_for_cup(build_stubbed(:series_cup, id: 99))).to be_nil
    end

    it 'uses only the best calc_participations_count participations for points' do
      # corrected points: cup1 = 10, cup2 = 15, cup3 = 12 - 4 = 8
      expect(person.ordered_participations).to eq [cup2, cup1]
      expect(person.points).to eq 25
    end

    it 'sums all points for all_points' do
      expect(person.all_points).to eq 33
    end

    it 'calculates time values' do
      expect(person.best_time).to eq 1800
      expect(person.best_time_without_nil).to eq 1800
      expect(person.sum_time).to eq 3700
    end

    it 'calculates best rank and its count' do
      expect(person.best_rank).to eq 1
      expect(person.best_rank_count).to eq 1
    end

    it 'returns valid participations from ordered participations' do
      expect(person.valid_participations).to eq [cup2, cup1]
    end
  end

  context 'when points are equal' do
    let(:cup1) { participation(1, time: 1900, points: 10) }
    let(:cup2) { participation(2, time: 1700, points: 10) }
    let(:cup3) { participation(3, time: 1800, points: 10) }

    before { [cup1, cup2, cup3].each { |p| person.add_participation(p) } }

    it 'orders by faster time' do
      expect(person.ordered_participations).to eq [cup2, cup3]
    end
  end

  context 'with invalid time' do
    let(:cup1) { participation(1, time: Firesport::INVALID_TIME, points: 10) }
    let(:cup2) { participation(2, time: 1700, points: 5) }

    before { [cup1, cup2].each { |p| person.add_participation(p) } }

    it 'limits sum time to invalid time and ignores invalid participations' do
      expect(person.sum_time).to eq Firesport::INVALID_TIME
      expect(person.valid_participations).to eq [cup2]
    end
  end

  context 'with equal best ranks' do
    let(:cup1) { participation(1, time: 1900, points: 10, rank: 1) }
    let(:cup2) { participation(2, time: 1700, points: 10, rank: 1) }
    let(:cup3) { participation(3, time: 1700, points: 10, rank: 4) }

    before { [cup1, cup2, cup3].each { |p| person.add_participation(p) } }

    it 'counts best ranks' do
      expect(person.best_rank).to eq 1
      expect(person.best_rank_count).to eq 2
    end
  end

  describe '#best_time_without_nil' do
    it 'returns value bigger than invalid time if no time exists' do
      allow(person).to receive(:best_time).and_return(nil)
      expect(person.best_time_without_nil).to eq Firesport::INVALID_TIME + 1
    end
  end

  describe '#<=>' do
    let(:other) { described_class.new(config:, person: build_stubbed(:person)) }

    before do
      person.add_participation(participation(1, time: 1900, points: 10))
      other.add_participation(participation(1, time: 1800, points: 10))
    end

    it 'sorts by best time if points are equal' do
      expect([person, other].sort).to eq [other, person]
    end

    it 'sorts by points first' do
      person.add_participation(participation(2, time: 2500, points: 1))
      expect([other, person].sort).to eq [person, other]
    end
  end
end
