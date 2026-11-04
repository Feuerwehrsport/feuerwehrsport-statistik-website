# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Bla::BadgeGenerator do
  let(:generator) { described_class.new }
  let(:bla_competition) do
    create(:competition, date: Date.new(2017, 5, 1), hl_male_for_bla_badge: true, hb_male_for_bla_badge: true,
                         hl_female_for_bla_badge: true, hb_female_for_bla_badge: true)
  end
  let(:other_competition) { create(:competition, date: Date.new(2017, 6, 1), name: 'Ohne Bla') }
  let(:old_competition) do
    create(:competition, date: Date.new(2015, 5, 1), name: 'Alt', hl_male_for_bla_badge: true,
                         hb_male_for_bla_badge: true)
  end
  let(:person) { create(:person) }

  before { travel_to(Time.zone.local(2018, 3, 1)) }

  def score(discipline, time, competition: bla_competition, person: self.person)
    create(:score, discipline, person:, competition:, time:)
  end

  describe '#people_with_badges' do
    it 'returns silver and bronze badges for matching times' do
      hl = score(:hl, 1650)
      hb = score(:hb, 1800)

      result = generator.people_with_badges
      expect(result.keys).to eq [person]
      gold, silver, bronze = result[person]
      expect(gold.hl_score).to be_nil
      expect(gold.hb_score).to be_nil
      expect(gold).not_to be_valid
      expect(silver).to have_attributes(status: 'silver', hl_score: hl, hb_score: hb, year: 2018)
      expect(silver).to be_valid
      expect(bronze).to have_attributes(status: 'bronze', hl_score: hl, hb_score: hb)
    end

    it 'ignores competitions not flagged for bla' do
      score(:hl, 1500, competition: other_competition)
      score(:hb, 1500, competition: other_competition)
      expect(generator.people_with_badges).to be_empty
    end

    it 'ignores slow people' do
      score(:hl, 1900)
      score(:hb, 1800)
      expect(generator.people_with_badges).to be_empty
    end

    it 'ignores non german people' do
      person.update!(nation: create(:nation, :ungarn))
      score(:hl, 1500)
      score(:hb, 1500)
      expect(generator.people_with_badges).to be_empty
    end

    it 'ignores people with gold badge' do
      score(:hl, 1500)
      score(:hb, 1500)
      create(:bla_badge, person:, status: :gold)
      expect(generator.people_with_badges).to be_empty
    end

    it 'returns no new badge if existing badge is equal or better' do
      score(:hl, 1650)
      score(:hb, 1800)
      create(:bla_badge, person:, status: :silver)
      gold, silver, bronze = generator.people_with_badges[person]
      expect(gold).to be_present
      expect(silver).to be_nil
      expect(bronze).to be_nil
    end

    it 'returns badges for women' do
      woman = create(:person, :female)
      hl = create(:score, :hl, person: woman, competition: bla_competition, time: 880,
                               single_discipline: create(:single_discipline, :hl_female))
      hb = create(:score, :hb, person: woman, competition: bla_competition, time: 1990,
                               single_discipline: create(:single_discipline, :hb_female))

      gold, silver, bronze = generator.people_with_badges[woman]
      expect(gold).to have_attributes(hl_score: nil, hb_score: nil)
      expect(silver).to have_attributes(hl_score: hl, hb_score: hb)
      expect(bronze).to have_attributes(hl_score: hl, hb_score: hb)
    end
  end

  describe '#badge_for' do
    it 'accepts 0.3 seconds tolerance for competitions before 2016' do
      hl = score(:hl, 1720, competition: old_competition)
      hb = score(:hb, 1870, competition: old_competition)
      badge = generator.badge_for(person, :silver, 1700, 1850)
      expect(badge).to have_attributes(hl_score: hl, hb_score: hb)
    end

    it 'does not accept tolerance since 2016' do
      score(:hl, 1720)
      score(:hb, 1870)
      badge = generator.badge_for(person, :silver, 1700, 1850)
      expect(badge).to have_attributes(hl_score: nil, hb_score: nil)
    end

    it 'ignores scores until ignore_bla_untill_year' do
      score(:hl, 1650)
      score(:hb, 1800)
      person.update!(ignore_bla_untill_year: 2017)
      badge = generator.badge_for(person, :silver, 1700, 1850)
      expect(badge).to have_attributes(hl_score: nil, hb_score: nil)

      person.update!(ignore_bla_untill_year: 2016)
      badge = generator.badge_for(person, :silver, 1700, 1850)
      expect(badge.hl_score).to be_present
    end

    it 'takes first matching score by date' do
      score(:hl, 1600, competition: create(:competition, date: Date.new(2018, 1, 1), hl_male_for_bla_badge: true))
      first = score(:hl, 1690)
      score(:hb, 1800)
      expect(generator.badge_for(person, :silver, 1700, 1850).hl_score).to eq first
    end

    it 'uses existing badge record of person' do
      existing = create(:bla_badge, person:, status: :bronze)
      score(:hl, 1500)
      score(:hb, 1500)
      expect(generator.badge_for(person, :gold, 1550, 1750)).to eq existing
    end
  end
end
