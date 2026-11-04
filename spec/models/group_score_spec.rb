# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GroupScore do
  let(:team) { create(:team) }
  let(:other_team) { create(:team, :mv) }
  let(:competition) { create(:competition) }
  let(:competition2018) { create(:competition, date: Date.parse('2018-05-01')) }
  let(:la) { create(:group_score_type) }
  let(:la_irregular) { create(:group_score_type, name: 'Sonderwertung', regular: false) }
  let(:gs) { create(:group_score_type, discipline: 'gs', name: 'GS') }
  let(:la_category) { create(:group_score_category, group_score_type: la, competition:) }
  let(:la_category2018) { create(:group_score_category, group_score_type: la, competition: competition2018) }
  let(:irregular_category) { create(:group_score_category, group_score_type: la_irregular, competition:) }
  let(:gs_category) { create(:group_score_category, group_score_type: gs, competition:) }

  def group_score(attributes = {})
    create(:group_score, { team:, group_score_category: la_category }.merge(attributes))
  end

  describe 'scopes' do
    let!(:la_a) { group_score(time: 2400, run: 'A') }
    let!(:la_b) { group_score(time: 2300, run: 'B') }
    let!(:la_a2) { group_score(time: 2200, run: 'A') }
    let!(:la_other) { group_score(team: other_team, time: 2500) }
    let!(:la2018) { group_score(group_score_category: la_category2018, time: 2100) }
    let!(:irregular) { group_score(group_score_category: irregular_category, time: 2000) }
    let!(:gs_female) { group_score(group_score_category: gs_category, gender: :female, time: 3000) }

    it 'filters by discipline, gender, type and regularity' do
      expect(described_class.discipline(:gs)).to eq [gs_female]
      expect(described_class.gender(:female)).to eq [gs_female]
      expect(described_class.regular).not_to include(irregular)
      expect(described_class.group_score_type(la_irregular)).to eq [irregular]
    end

    it 'filters by year, competition, category, team and time' do
      expect(described_class.year(2018)).to eq [la2018]
      expect(described_class.competition(competition2018.id)).to eq [la2018]
      expect(described_class.group_score_category(gs_category.id)).to eq [gs_female]
      expect(described_class.team(other_team.id)).to eq [la_other]
      expect(described_class.where_time_like('21')).to eq [la2018]
    end

    it 'filters by person' do
      person = create(:person)
      create(:person_participation, person:, group_score: la_other)
      expect(described_class.person(person.id)).to eq [la_other]
    end

    it 'returns best score per run' do
      expect(described_class.group_score_category(la_category.id).best_of_competition.map(&:id))
        .to contain_exactly(la_a2.id, la_b.id, la_other.id)
    end

    it 'returns best score per team for single run' do
      expect(described_class.group_score_category(la_category.id).best_of_competition(true).map(&:id))
        .to contain_exactly(la_a2.id, la_other.id)
    end

    it 'returns best regular score per team of year' do
      expect(described_class.best_of_year(2017, :la, :male).map(&:id)).to contain_exactly(la_a2.id, la_other.id)
    end

    it 'returns best regular score per team of all time' do
      expect(described_class.best_of(:la, :male, nil).map(&:id)).to contain_exactly(la2018.id, la_other.id)
    end

    it 'returns scores with too few members' do
      group_score = la_other
      create_list(:person_participation, 6, group_score:)
      create(:person_participation, group_score: la_a, person: create(:person, first_name: 'Bernd'))
      7.times { |i| create(:person_participation, group_score: la_b, position: i + 1) }

      expect(described_class.without_members(:la).map(&:id)).to contain_exactly(
        la_a.id, la_a2.id, la_other.id, la2018.id, irregular.id
      )
      expect(described_class.without_members(:la).map(&:id)).not_to include(la_b.id)
    end
  end

  describe 'entity' do
    it 'is the team' do
      record = group_score
      expect(record.entity).to eq team
      expect(record.entity_id).to eq team.id
      expect(record.competition).to eq competition
      expect(record.discipline).to eq 'la'
    end
  end

  describe 'validation' do
    it 'requires gender and time' do
      record = described_class.new(team:, group_score_category: la_category, team_number: 1)
      expect(record).not_to be_valid
      expect(record.errors.attribute_names).to include(:gender, :time)
    end
  end

  describe 'similar scores' do
    let!(:first) { group_score(time: 2400, run: 'A') }
    let!(:second) { group_score(time: 2200, run: 'B') }
    let!(:third) { group_score(time: 2300, run: 'A') }

    before do
      group_score(time: 2000, team_number: 2)
      group_score(time: 2000, gender: :female)
      group_score(time: 2000, group_score_category: gs_category)
    end

    it 'returns scores of same team, team number, category and gender' do
      expect(first.similar_scores).to eq [first, second, third]
      expect(first.competition_scores_from_team).to eq [second, third, first]
      expect(first.competition_scores_from_team_with_run).to eq [third, first]
    end
  end

  describe '#<=>' do
    it 'compares best times first' do
      fast = group_score(time: 2000)
      slow = group_score(team: other_team, time: 2100)
      expect(fast <=> slow).to eq(-1)
      expect([slow, fast].max).to eq slow
    end

    it 'compares following times and prefers more runs' do
      a = group_score(time: 2000)
      group_score(time: 2500)
      b = group_score(team: other_team, time: 2000)
      expect(a <=> b).to eq(-1)

      group_score(team: other_team, time: 2500)
      expect(described_class.find(a.id) <=> described_class.find(b.id)).to eq 0

      c = group_score(team: other_team, time: 2000, team_number: 2)
      group_score(team: other_team, time: 2300, team_number: 2)
      expect(described_class.find(a.id) <=> c).to eq 1
    end

    it 'can compare by run' do
      a = group_score(time: 2000, run: 'A')
      group_score(time: 1900, run: 'B')
      b = group_score(team: other_team, time: 1950, run: 'A')
      expect(a.sort_method(b, method: :competition_scores_from_team_with_run)).to eq 1
      expect(a.sort_method(b)).to eq(-1)
    end
  end
end
