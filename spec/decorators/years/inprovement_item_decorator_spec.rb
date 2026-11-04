# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Years::InprovementItemDecorator do
  let(:person) { create(:person) }
  let(:item) { Years::InprovementItem.new(person, 2018) }
  let(:decorated) { item.decorate }

  before do
    item.current_scores.concat([1800, 1900, 2000].map { |time| create(:score, person:, time:) })
    item.last_scores.concat([2100, 2200, 2312].map { |time| create(:score, person:, time:) })
  end

  it 'is the decorator of an inprovement item' do
    expect(decorated).to be_a described_class
  end

  it 'formats times' do
    expect(decorated.second_current_average).to eq '19,00'
    expect(decorated.second_last_average).to eq '22,04'
    expect(decorated.second_difference).to eq '3,04'
  end

  it 'formats invalid averages' do
    item.current_scores.clear
    expect(decorated.second_current_average).to eq 'D'
  end

  it 'decorates associations' do
    expect(decorated.person).to be_decorated
    expect(decorated.person.full_name).to eq 'Alfred Meier'
    expect(decorated.current_scores).to all(be_decorated)
    expect(decorated.last_scores.map(&:second_time)).to eq %w[21,00 22,00 23,12]
  end
end
