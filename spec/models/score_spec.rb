# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Score do
  let(:nation) { create(:nation) }
  let(:alfred) { create(:person, nation:) }
  let(:johanna) { create(:person, :female, nation:) }
  let(:foreigner) { create(:person, first_name: 'Istvan', nation: create(:nation, :ungarn)) }
  let(:team) { create(:team) }
  let(:competition) { create(:competition) }
  let(:competition2018) { create(:competition, date: Date.parse('2018-05-01')) }
  let(:hb_male) { create(:single_discipline, :hb_male) }
  let(:hl_male) { create(:single_discipline, :hl_male) }

  def score(attributes = {})
    create(:score, { person: alfred, competition:, single_discipline: hb_male, team: }.merge(attributes))
  end

  describe 'scopes' do
    let!(:hb) { score(time: 1900) }
    let!(:hb_slow) { score(time: 2000) }
    let!(:hl) { score(single_discipline: hl_male, time: 1600, competition: competition2018) }
    let!(:final) { score(time: 1850, team_number: -1) }
    let!(:out_of_competition) { score(time: 1700, team_number: -5, team: nil) }
    let!(:female) { score(person: johanna, time: 2200) }
    let!(:foreign) { score(person: foreigner, time: 1500) }

    it 'filters by discipline, gender and nation' do
      expect(described_class.hb).to contain_exactly(hb, hb_slow, final, out_of_competition, female, foreign)
      expect(described_class.hl).to eq [hl]
      expect(described_class.gender(:female)).to eq [female]
      expect(described_class.german).not_to include(foreign)
    end

    it 'filters by team number' do
      expect(described_class.no_finals).to contain_exactly(hb, hb_slow, hl, female, foreign)
      expect(described_class.finals(-1)).to eq [final]
      expect(described_class.out_of_competition).to eq [out_of_competition]
      expect(described_class.with_team).not_to include(out_of_competition)
    end

    it 'filters by ids, year and time' do
      expect(described_class.year(2018)).to eq [hl]
      expect(described_class.competition(competition2018.id)).to eq [hl]
      expect(described_class.person(johanna.id)).to eq [female]
      expect(described_class.team(nil)).to eq [out_of_competition]
      expect(described_class.where_time_like('85')).to eq [final]
    end

    it 'returns best score per person, competition and discipline' do
      expect(described_class.best_of_competition.map(&:id)).to contain_exactly(
        out_of_competition.id, hl.id, female.id, foreign.id
      )
    end

    it 'returns best german score per person of year' do
      expect(described_class.best_of_year(2017, :hb, :male).map(&:id)).to eq [out_of_competition.id]
      expect(described_class.best_of_year(2018, :hb, :male)).to be_empty
    end

    it 'returns best german score per person of all time' do
      expect(described_class.best_of(:hl, :male, nil).map(&:id)).to eq [hl.id]
    end
  end

  describe '#uniq_team_id' do
    it 'combines competition, team and team number' do
      expect(score(team_number: 2).uniq_team_id).to eq "#{competition.id}-#{team.id}-2"
    end
  end

  describe 'entity' do
    it 'is the person' do
      record = score
      expect(record.entity).to eq alfred
      expect(record.entity_id).to eq alfred.id
    end
  end

  describe '#similar_scores' do
    it 'returns scores of same person, competition, discipline and team number ordered by time' do
      first = score(time: 2000)
      second = score(time: 1900)
      score(time: 1800, team_number: 2)
      score(time: 1800, single_discipline: hl_male)
      score(time: 1800, competition: competition2018)

      expect(first.similar_scores).to eq [second, first]
    end
  end

  describe '#<=>' do
    let(:bernd) { create(:person, first_name: 'Bernd', nation:) }

    it 'compares the best times first' do
      expect(score(time: 1900) <=> score(person: bernd, time: 2000)).to eq(-1)
    end

    it 'compares the following times on equal best time' do
      a = score(time: 1900)
      score(time: 2100)
      b = score(person: bernd, time: 1900)
      score(person: bernd, time: 2000)

      expect(a <=> b).to eq 1
      expect(b <=> a).to eq(-1)
    end

    it 'prefers more scores on equal times' do
      a = score(time: 1900)
      score(time: 2000)
      b = score(person: bernd, time: 1900)

      expect(a <=> b).to eq(-1)
      expect(b <=> a).to eq 1
      expect(a <=> a).to eq 0 # rubocop:disable Lint/BinaryOperatorWithIdenticalOperands
    end
  end

  describe 'bla badges' do
    let(:hl) { score(single_discipline: hl_male, time: 1700) }
    let(:hb) { score(time: 1900) }
    let!(:badge) { create(:bla_badge, person: alfred, hl_score: hl, hb_score: hb) }

    it 'finds badges by hl score' do
      expect(hl.hl_bla_badges).to eq [badge]
    end

    it 'finds badges by hb score' do
      expect(hb.hb_bla_badges).to eq [badge]
    end
  end
end
