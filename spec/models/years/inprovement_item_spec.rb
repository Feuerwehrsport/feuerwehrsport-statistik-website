# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Years::InprovementItem do
  let(:item) { described_class.new(:person, year) }
  let(:year) { 2018 }

  def scores(*times)
    times.map { |time| build(:score, time:) }
  end

  it 'starts with empty score lists' do
    expect(item.current_scores).to eq []
    expect(item.last_scores).to eq []
  end

  it 'uses average of best three scores' do
    item.current_scores.concat(scores(2000, 1800, 2500, 1900))
    item.last_scores.concat(scores(2200, 2100, 2000))
    expect(item.current_average).to eq 1900
    expect(item.last_average).to eq 2100
    expect(item.difference).to eq 200
  end

  it 'returns invalid time with too few scores' do
    item.current_scores.concat(scores(2000, 1800))
    item.last_scores.concat(scores(2200, 2100, 2000))
    expect(item.current_average).to eq Firesport::INVALID_TIME
    expect(item.difference).to eq 2100 - Firesport::INVALID_TIME
  end

  context 'with year 2020' do
    let(:year) { 2020 }

    it 'only needs two current scores' do
      item.current_scores.concat(scores(2000, 1800))
      item.last_scores.concat(scores(2000, 1800))
      expect(item.current_average).to eq 1900
      expect(item.last_average).to eq Firesport::INVALID_TIME
    end
  end

  context 'with year 2021' do
    let(:year) { 2021 }

    it 'only needs two last scores' do
      item.current_scores.concat(scores(2000, 1800))
      item.last_scores.concat(scores(2000, 1800, 3000))
      expect(item.current_average).to eq Firesport::INVALID_TIME
      expect(item.last_average).to eq 1900
    end
  end

  it 'sorts by difference descending' do
    small = described_class.new(:small, 2018)
    small.current_scores.concat(scores(2000, 2000, 2000))
    small.last_scores.concat(scores(2100, 2100, 2100))
    big = described_class.new(:big, 2018)
    big.current_scores.concat(scores(1500, 1500, 1500))
    big.last_scores.concat(scores(2100, 2100, 2100))

    expect([small, big].sort.map(&:person)).to eq %i[big small]
  end
end
