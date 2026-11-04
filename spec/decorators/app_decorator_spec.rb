# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AppDecorator do
  describe '.localizes_gender' do
    let(:person) { build(:person, :female).decorate }

    it 'translates gender' do
      expect(person.gender_translated).to eq 'weiblich'
      expect(person.gender_symbol).to eq '♀'
      expect(person.gender).to eq :female
    end
  end

  describe '.localizes_boolean' do
    it 'returns empty string for nil values' do
      competition = build(:competition, hb_male_for_bla_badge: nil).decorate
      expect(competition.hb_male_for_bla_badge_translated).to eq ''
    end
  end

  describe '.localizes' do
    it 'defines iso helpers' do
      competition = build(:competition).decorate
      expect(competition.date_iso).to eq '2017-05-01'
      expect(competition.date_date_iso).to eq '2017-05-01'
      competition.object.date = nil
      expect(competition.date_iso).to be_nil
      expect(competition.date_date_iso).to be_nil
    end
  end

  describe '#to_serializer' do
    it 'returns serializer for decorated object' do
      place = build(:place, id: 3).decorate
      serializer = place.to_serializer
      expect(serializer).to be_a PlaceSerializer
      expect(serializer.object).to eq place
    end

    it 'returns decorator itself if no serializer exists' do
      score_type = build(:score_type).decorate
      expect(score_type.to_serializer).to be_a ScoreTypeSerializer
      year = Year.new.decorate
      expect(year.to_serializer).to eq year
    end
  end

  describe 'discipline and gender helpers' do
    let(:decorated) { build(:place).decorate }

    it 'returns discipline information' do
      expect(decorated.discipline_name(:hb)).to eq 'Hindernisbahn'
      expect(decorated.discipline_name_short(:la)).to eq 'LA'
      expect(decorated.discipline_color(:hl)).to eq '#e4d354'
      expect(decorated.group_discipline?(:la)).to be true
      expect(decorated.group_discipline?('hb')).to be false
      expect(decorated.discipline_image(:hb))
        .to match(%r{<img width="20" title="Hindernisbahn" src="/assets/disciplines/hb-.*\.png" />})
      expect(decorated.discipline_image_name_short(:hb, :male)).to match(/<img .*> HB ♂\z/)
    end

    it 'returns gender information' do
      expect(decorated.g(:male)).to eq 'männlich'
      expect(decorated.g(1)).to eq 'männlich'
      expect(decorated.g(0)).to eq 'weiblich'
      expect(decorated.g_symbol(:female)).to eq '♀'
      expect(decorated.g_color(:male)).to eq 'blue'
      expect(decorated.gender_color(:female)).to eq '#FEAE97'
      expect(decorated.gender_color(1)).to eq '#97E6FE'
    end
  end
end
