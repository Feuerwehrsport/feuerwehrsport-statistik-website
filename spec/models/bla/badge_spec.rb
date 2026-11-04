# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Bla::Badge do
  let(:person) { create(:person) }
  let(:competition) { create(:competition, hl_male_for_bla_badge: true, hb_male_for_bla_badge: true) }
  let(:hl_score) { create(:score, :hl, person:, competition:, time: 1650) }
  let(:hb_score) { create(:score, :hb, person:, competition:, time: 1800) }
  let(:badge) { described_class.new(person:, hl_score:, hb_score:, year: 2017, status: :silver) }

  describe 'validation' do
    it 'is valid and copies times from scores' do
      expect(badge).to be_valid
      expect(badge.hl_time).to eq 1650
      expect(badge.hb_time).to eq 1800
    end

    it 'is invalid with scores of wrong discipline' do
      badge.hl_score = hb_score
      expect(badge).not_to be_valid
      expect(badge.errors).to include(:hl_score)
    end

    it 'is invalid with scores of other person' do
      other_person = create(:person, first_name: 'Other')
      badge.hb_score = create(:score, :hb, person: other_person, competition:)
      expect(badge).not_to be_valid
      expect(badge.errors).to include(:hb_score)
    end

    it 'is invalid if time does not match score time' do
      badge.hl_time = 1000
      expect(badge).not_to be_valid
      expect(badge.errors).to include(:hl_time)
    end

    it 'requires hl time for men' do
      badge.hl_score = nil
      expect(badge).not_to be_valid
      expect(badge.errors).to include(:hl_time)
    end

    context 'with female person' do
      let(:person) { create(:person, :female) }

      it 'does not require hl time until 2015' do
        badge.assign_attributes(hl_score: nil, year: 2015)
        expect(badge).to be_valid
      end

      it 'requires hl time since 2016' do
        badge.assign_attributes(hl_score: nil, year: 2016)
        expect(badge).not_to be_valid
      end
    end
  end

  describe 'comparison' do
    it 'compares by status' do
      gold = described_class.new(status: 'gold')
      silver = described_class.new(status: 'silver')
      bronze = described_class.new(status: 'bronze')
      expect([bronze, gold, silver].max).to eq gold
      expect(silver <=> bronze).to eq 1
      expect(bronze <=> gold).to eq(-1)
      expect(described_class.new.status_as_index).to eq 0
    end
  end

  describe '#next_badge' do
    it 'returns faster scores of person' do
      faster_hl = create(:score, :hl, person:, competition:, time: 1500)
      create(:score, :hl, person:, competition:, time: 1550)
      faster_hb = create(:score, :hb, person:, competition:, time: 1700)
      badge.save!

      expect(badge.next_badge.hl_score).to eq faster_hl
      expect(badge.current_hl_time).to eq 1500
      expect(badge.current_hb_time).to eq faster_hb.time
    end

    it 'returns nil times without faster scores' do
      badge.save!
      expect(badge.current_hl_time).to be_nil
      expect(badge.current_hb_time).to be_nil
    end
  end

  describe 'score destroy' do
    before { badge.save! }

    it 'nullifies hl score' do
      described_class.where(id: badge.id).update_all(hl_time: nil)
      hl_score.destroy!
      expect(badge.reload.hl_score_id).to be_nil
    end

    it 'nullifies hb score' do
      hb_score.destroy!
      expect(badge.reload.hb_score_id).to be_nil
    end
  end

  describe '.person' do
    it 'filters by person' do
      badge.save!
      expect(described_class.person(person.id)).to eq [badge]
      expect(described_class.person(person.id + 1)).to be_empty
    end
  end
end
