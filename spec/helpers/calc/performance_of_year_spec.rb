# frozen_string_literal: true

require 'rails_helper'

describe Calc::PerformanceOfYear do
  describe '.get' do
    it 'returns nothing without scores' do
      expect(described_class.get(2017)).to eq []
    end

    context 'with scores' do
      before do
        create(:score, :hl, time: 1800)
        create(:group_score, time: 2400)
      end

      it 'returns only performances with entries' do
        performances = described_class.get(2017)
        expect(performances.map { |p| [p.klass, p.key, p.gender] }).to eq [
          [Calc::PerformanceOfYear::Person, :hl, :male],
          [Calc::PerformanceOfYear::Team, :la, :male],
        ]
        expect(performances.first.entries.map(&:valid_time_average)).to eq [1800]
      end

      it 'ignores other years' do
        expect(described_class.get(2018)).to eq []
      end
    end
  end

  describe Calc::PerformanceOfYear::Base do
    let(:entry) { described_class.new(:entity) }

    def add_times(*times)
      times.each { |time| entry.scores.push(build(:score, time:)) }
    end

    it 'handles entries without valid times' do
      add_times(Firesport::INVALID_TIME)
      expect(entry.valid_time_count).to eq 0
      expect(entry.invalid_time_count).to eq 1
      expect(entry.valid_time_average).to eq Firesport::INVALID_TIME
      expect(entry.second_valid_time_average).to eq 'D'
    end

    it 'calculates points with bonus and malus' do
      add_times(1900, 2100, Firesport::INVALID_TIME)
      expect(entry.valid_time_sum).to eq 4000
      expect(entry.valid_time_average).to eq 2000
      expect(entry.second_valid_time_average).to eq '20,00'
      # 2000 + 1 * 15 - (10 + (10 - 1/23))
      expect(entry.points).to be_within(0.0001).of(2015 - 20 + (1.0 / 23))
      expect(entry.rounded_points).to eq 1995
    end

    it 'limits the bonus to the first 16 runs' do
      add_times(*Array.new(20, 2000))
      bonus = (0..15).sum { |z| 10 - ((z**2) / 23.0) }
      expect(entry.points).to be_within(0.0001).of(2000 - bonus)
    end
  end
end
