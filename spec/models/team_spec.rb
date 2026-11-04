# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Team do
  let(:team) { create(:team) }
  let(:other_team) { create(:team, :mv) }
  let(:alfred) { create(:person) }
  let(:johanna) { create(:person, :female) }
  let(:hb_male) { create(:single_discipline, :hb_male) }
  let(:hl_male) { create(:single_discipline, :hl_male) }
  let(:hl_female) { create(:single_discipline, :hl_female) }
  let(:competition) { create(:competition) }
  let(:la) { create(:group_score_type) }
  let(:gs) { create(:group_score_type, discipline: 'gs', name: 'GS') }
  let(:la_category) { create(:group_score_category, competition:, group_score_type: la) }
  let(:gs_category) { create(:group_score_category, competition:, group_score_type: gs) }

  describe '.normalize_name' do
    it 'removes prefixes and suffixes' do
      expect(described_class.normalize_name('FF Warin')).to eq 'Warin'
      expect(described_class.normalize_name('Feuerwehr Warin II')).to eq 'Warin'
      expect(described_class.normalize_name('Team Warin A 1')).to eq 'Warin'
      expect(described_class.normalize_name('Warin IV')).to eq 'Warin'
      expect(described_class.normalize_name('Warin E')).to eq 'Warin'
      expect(described_class.normalize_name('Alt Warin')).to eq 'Alt Warin'
    end
  end

  describe 'scopes' do
    let!(:checked) { create(:team, :mv, checked_at: Time.current) }

    before { team }

    it 'filters by status and checked state' do
      expect(described_class.status(:team)).to eq [checked]
      expect(described_class.status('fire_station')).to eq [team]
      expect(described_class.unchecked).to eq [team]
    end

    it 'searches by name' do
      expect(described_class.search('warin')).to eq [team]
      expect(described_class.search('Team MV')).to eq [checked]
      expect(described_class.where_name_like('FF Wrn')).to eq [team]
      expect(described_class.where_name_like('Team Mecklenburg')).to eq [checked]
    end

    it 'searches by spelling' do
      create(:team_spelling, team:, name: 'FF Warinho', shortcut: 'Warinho')
      expect(described_class.where_name_like('Warinho')).to eq [team]
    end

    it 'filters by person and competition' do
      create(:score, team:, person: alfred, competition:)
      expect(described_class.person(alfred.id)).to eq [team]
      expect(described_class.competition(competition.id)).to eq [team]
      expect(described_class.competition(0)).to be_empty
    end
  end

  describe 'counts' do
    def discipline_counts(record)
      %i[hb hl gs fs la].index_with { |discipline| record.public_send(discipline) }
    end

    before do
      create(:score, team:, person: alfred, competition:, single_discipline: hb_male)
      create(:score, team:, person: alfred, competition:, single_discipline: hb_male)
      create(:score, team:, person: alfred, competition:, single_discipline: hl_male)
      create(:score, team: other_team, person: alfred, competition:, single_discipline: hl_male)
      la_score = create(:group_score, team:, group_score_category: la_category)
      create(:person_participation, person: alfred, group_score: la_score, position: 1)
      create(:person_participation, person: johanna, group_score: la_score, position: 2)
      create(:group_score, team:, group_score_category: gs_category, gender: :female)
    end

    it 'counts scores of a person' do
      expect(team.person_scores_count(alfred)).to eq 4
      expect(team.person_scores_count(johanna)).to eq 1
      expect(other_team.person_scores_count(alfred)).to eq 1
    end

    it 'counts disciplines per member' do
      members = team.members_with_discipline_count.index_by(&:id)
      expect(members.values).to all(be_a(Calculation::TeamPerson))
      expect(discipline_counts(members[alfred.id])).to eq(hb: 2, hl: 1, gs: nil, fs: nil, la: 1)
      expect(discipline_counts(members[johanna.id])).to eq(hb: nil, hl: nil, gs: nil, fs: nil, la: 1)
    end

    it 'counts disciplines per competition' do
      competitions = team.competitions_with_discipline_count
      expect(competitions.map(&:id)).to eq [competition.id]
      expect(competitions.first).to be_a(Calculation::TeamCompetition)
      expect(discipline_counts(competitions.first)).to eq(hb: 2, hl: 1, gs: 1, fs: nil, la: 1)
    end

    it 'updates cached counts' do
      described_class.update_members_and_competitions_count
      expect(team.reload.members_count).to eq 2
      expect(team.competitions_count).to eq 1
      expect(other_team.reload.members_count).to eq 1
    end

    it 'groups disciplines by type' do
      disciplines = team.group_disciplines
      expect(disciplines.map { |d| [d.discipline, d.gender, d.types.map { |t| t.type.object }] }).to eq [
        [:gs, :female, [gs]],
        [:la, :male, [la]],
      ]
    end
  end

  describe '#group_assessments' do
    let(:competition) { create(:competition, score_type: create(:score_type, people: 3, run: 3, score: 2)) }
    let(:without_assessment) { create(:competition, date: Date.parse('2018-01-01')) }
    let(:bernd) { create(:person, first_name: 'Bernd') }

    before do
      create(:score, team:, person: alfred, competition:, single_discipline: hl_male, time: 1700)
      create(:score, team:, person: alfred, competition:, single_discipline: hl_male, time: 1600)
      create(:score, team:, person: bernd, competition:, single_discipline: hl_male, time: 1800)
      create(:score, team:, person: bernd, competition:, single_discipline: hl_male, time: 1500, team_number: -1)
      create(:score, team:, person: johanna, competition:, single_discipline: hl_female, time: 1900, team_number: 2)
      create(:score, team:, person: alfred, competition: without_assessment, single_discipline: hl_male, time: 1000)
    end

    it 'calculates team times per competition' do
      assessments = team.group_assessments
      expect(assessments.map { |a| [a.discipline, a.gender, a.scores.count] }).to eq [
        [:hl, :female, 1],
        [:hl, :male, 1],
        [:hb, :female, 0],
        [:hb, :male, 0],
      ]

      male = assessments[1].scores.first
      expect(male).to be_decorated
      expect(male.time).to eq 3400
      expect(male.scores.map(&:time)).to eq [1600, 1800]
      expect(male.team_number).to eq 1

      female = assessments[0].scores.first
      expect(female.team_number).to eq 2
      expect(female.second_time).to eq 'D'
    end
  end

  describe 'GroupDisciplineType' do
    it 'calculates times' do
      scores = [2200, 2400, Firesport::INVALID_TIME].map { |time| build(:group_score, time:).decorate }
      type = Team::GroupDisciplineType.new(scores, la)
      expect(type.valid_scores.map(&:time)).to eq [2200, 2400]
      expect(type.best_time).to eq '22,00'
      expect(type.average_time).to eq '23,00'
    end
  end

  describe '#merge_to' do
    it 'raises for same team' do
      expect { team.merge_to(team) }.to raise_error(ActiveRecord::ActiveRecordError, 'same id')
    end

    it 'moves all associated records' do
      score = create(:score, team:)
      group_score = create(:group_score, team:)
      spelling = create(:team_spelling, team:)
      link = create(:link, linkable: team)

      team.merge_to(other_team)

      expect(score.reload.team).to eq other_team
      expect(group_score.reload.team).to eq other_team
      expect(spelling.reload.team).to eq other_team
      expect(link.reload.linkable).to eq other_team
    end
  end
end
