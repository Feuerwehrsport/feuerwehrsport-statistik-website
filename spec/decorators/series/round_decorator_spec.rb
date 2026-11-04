# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Series::RoundDecorator do
  let(:round) { create(:series_round, full_cup_count: 2, official: true) }
  let(:decorator) { round.decorate }

  it 'builds names' do
    expect(decorator.to_s).to eq 'D-Cup 2016'
    expect(decorator.page_title).to eq 'D-Cup 2016 - Wettkampfserie'
    expect(decorator.official_translated).to eq 'Ja'
  end

  describe '#cup_count_with_status' do
    it 'shows missing cups' do
      create(:series_cup, round:)
      expect(decorator.cup_count_with_status).to eq '1 von 2'
    end

    it 'shows only count if complete' do
      create(:series_cup, round:)
      create(:series_cup, round:, competition: create(:competition, date: Date.new(2017, 6, 1)))
      expect(decorator.cup_count_with_status).to eq 2
    end
  end
end
