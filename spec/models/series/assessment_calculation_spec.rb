# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Series::AssessmentCalculation do
  let(:person_config) do
    {
      key: 'female',
      disciplines: ['hb'],
      name: 'Frauen',
      calc_participations_count: 2,
      min_participations_count: 2,
      ranking_logic: %w[points best_time],
    }
  end
  let(:round) { create(:series_round, full_cup_count: 2, person_assessments_config_jsonb: [person_config]) }
  let(:cup1) { create(:series_cup, round:, competition: create(:competition, date: Date.new(2016, 5, 1))) }
  let(:cup2) { create(:series_cup, round:, competition: create(:competition, date: Date.new(2016, 6, 1))) }
  let(:assessment) { create(:series_person_assessment, round:, discipline: 'hb', key: 'female') }
  let(:anna) { create(:person, :female, first_name: 'Anna') }
  let(:berta) { create(:person, :female, first_name: 'Berta') }
  let(:clara) { create(:person, :female, first_name: 'Clara') }
  let(:config) { round.person_config_for('female') }
  let(:rows) { described_class.new(config).rows }

  def participate(person, cup, points:, time:, rank: 1, points_correction: nil)
    create(:series_person_participation, person_assessment: assessment, person:, cup:, points:, time:, rank:,
                                         points_correction:)
  end

  def ranking
    rows.map { |row| [row.person.first_name, row.rank] }
  end

  context 'when round is not completed' do
    before do
      participate(anna, cup1, points: 10, time: 1800)
      participate(berta, cup1, points: 12, time: 1900)
      participate(clara, cup1, points: 10, time: 1700)
    end

    it 'ranks all entities even with too few participations' do
      expect(ranking).to eq [['Berta', 1], ['Clara', 2], ['Anna', 3]]
      expect(rows.first).to be_a Series::Person
      expect(rows.first.round).to eq round
    end

    it 'ignores participations of other assessment keys' do
      other = create(:series_person_assessment, round:, discipline: 'hb', key: 'male')
      create(:series_person_participation, person_assessment: other, person: create(:person), cup: cup1)
      expect(rows.count).to eq 3
    end
  end

  context 'when round is completed' do
    before do
      participate(anna, cup1, points: 10, time: 1800)
      participate(anna, cup2, points: 10, time: 1800)
      participate(berta, cup1, points: 15, time: 1900)
      participate(clara, cup1, points: 12, time: 1800)
      participate(clara, cup2, points: 3, time: 1900, points_correction: 5)
    end

    it 'removes rank of entities with too few participations' do
      expect(ranking.to_h).to eq('Anna' => 1, 'Clara' => 1, 'Berta' => nil)
    end

    it 'gives same rank to equal entities and skips following rank' do
      dora = create(:person, :female, first_name: 'Dora')
      participate(dora, cup1, points: 1, time: 2000)
      participate(dora, cup2, points: 1, time: 2000)

      expect(ranking.to_h).to eq('Anna' => 1, 'Clara' => 1, 'Dora' => 3, 'Berta' => nil)
    end

    it 'lists entities without rank after ranked entities' do
      dora = create(:person, :female, first_name: 'Dora')
      participate(dora, cup1, points: 1, time: 2000)
      participate(dora, cup2, points: 1, time: 2000)

      # Berta has more points than Dora, but no rank
      expect(ranking.last).to eq ['Berta', nil]
    end
  end

  context 'with honor ranking logic' do
    let(:person_config) do
      super().merge(ranking_logic: %w[points], honor_ranking_logic: %w[points best_time])
    end
    let(:dora) { create(:person, :female, first_name: 'Dora') }

    before do
      participate(anna, cup1, points: 10, time: 1900)
      participate(berta, cup1, points: 10, time: 1800)
      participate(clara, cup1, points: 5, time: 1700)
      participate(dora, cup1, points: 5, time: 1600)
    end

    it 'recalculates the first places with honor ranking logic' do
      # points only: Anna/Berta 1, Clara/Dora 3 - honor logic resolves the ties
      expect(ranking).to eq [['Berta', 1], ['Anna', 2], ['Dora', 3], ['Clara', 4]]
    end
  end

  context 'with team entity' do
    let(:round) { create(:series_round, full_cup_count: 2) }
    let(:assessment) { create(:series_team_assessment, round:, discipline: 'la', key: 'male') }
    let(:team) { create(:team) }
    let(:config) { round.team_config_for('male') }

    def participate_team(team_number, cup, points:, time:, rank:)
      create(:series_team_participation, team_assessment: assessment, team:, team_number:, cup:, points:, time:,
                                         rank:)
    end

    before do
      participate_team(1, cup1, points: 10, time: 2500, rank: 2)
      participate_team(2, cup1, points: 15, time: 2300, rank: 1)
      participate_team(1, cup2, points: 15, time: 2400, rank: 1)
    end

    it 'groups by team and team number' do
      expect(rows.map { |row| [row.team_number, row.points, row.rank] }).to eq [[1, 15, 1], [2, 15, 1]]
      expect(rows.first).to be_a Series::Team
    end
  end
end
