# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Series::Round do
  let(:round) { create(:series_round, full_cup_count: 2) }

  describe 'assessment configs' do
    it 'builds configs with round and entity key' do
      configs = round.team_assessments_configs
      expect(configs.map(&:key)).to eq %w[female male]
      expect(configs.map(&:round).uniq).to eq [round]
      expect(configs.map(&:entity_key).uniq).to eq [:team]
      expect(round.person_assessments_configs.map(&:entity_key)).to eq [:person]
    end

    it 'finds configs by key' do
      expect(round.team_config_for('male').name).to eq 'Männer'
      expect(round.person_config_for('female').disciplines).to eq ['hb']
      expect(round.person_config_for('male')).to be_nil
    end

    it 'collects all disciplines' do
      expect(round.disciplines).to eq %w[hb la]
    end

    it 'is invalid with invalid config entries' do
      round.team_assessments_config_jsonb = [{ key: 'female', disciplines: ['la'] }]
      expect(round).not_to be_valid
      expect(round.errors[:team_assessments_config_jsonb]).to include(a_string_starting_with('Eintrag 0: '))
      expect(round.errors[:team_assessments_config_jsonb_text]).to include(a_string_starting_with('Eintrag 0: '))
    end

    it 'is invalid if config is not an array' do
      round.person_assessments_config_jsonb = { key: 'female' }
      expect(round.person_assessments_configs).to eq []
      expect(round.errors[:person_assessments_config_jsonb]).to be_present
    end

    it 'is invalid if config entries are not hashes' do
      round.person_assessments_config_jsonb = ['female']
      expect(round.person_assessments_configs).to eq []
      expect(round.errors[:person_assessments_config_jsonb_text]).to be_present
    end
  end

  describe 'cup counting' do
    it 'calculates left cups and completion' do
      expect(round.cup_count).to eq 0
      expect(round.cups_left).to eq 2
      expect(round).not_to be_complete

      create(:series_cup, round:, competition: create(:competition, date: Date.new(2016, 5, 1)))
      create(:series_cup, round:, competition: create(:competition, date: Date.new(2016, 6, 1)))
      expect(round.cups_left).to eq 0
      expect(round).to be_complete
    end

    it 'uses cup_count of scope if present' do
      create(:series_cup, round:)
      create(:series_round, year: 2017)

      rounds = described_class.cup_count.to_a
      expect(rounds).to eq [round]
      expect(rounds.first.cup_count).to eq 1
      expect(rounds.first.cups_left).to eq 1
    end
  end

  context 'with team participations' do
    let(:team) { create(:team) }
    let(:other_team) { create(:team, name: 'FF Other', shortcut: 'Other') }
    let(:cup) { create(:series_cup, round:) }
    let(:assessment) { create(:series_team_assessment, round:, discipline: 'la', key: 'female') }

    before do
      create(:series_team_participation, team_assessment: assessment, cup:, team:, team_gender: 0, team_number: 1)
      create(:series_team_participation, team_assessment: assessment, cup:, team:, team_gender: 0, team_number: 2,
                                         points: 14, time: 2000)
      create(:series_team_participation, team_assessment: assessment, cup:, team: other_team, team_gender: 0)
    end

    describe '.with_team' do
      it 'finds rounds by team and gender' do
        expect(described_class.with_team(team.id, :female)).to eq [round]
        expect(described_class.with_team(team.id, 'female')).to eq [round]
        expect(described_class.with_team(team.id, :male)).to eq []
        expect(described_class.with_team(team.id, 0)).to eq [round]
      end
    end

    describe '.for_team' do
      it 'returns rounds grouped by name with every team number' do
        result = described_class.for_team(team.id, :female)
        expect(result.keys).to eq ['D-Cup']
        expect(result['D-Cup'].map(&:team_number)).to contain_exactly(1, 2)
        expect(result['D-Cup'].map(&:round)).to all(eq round)
        expect(result['D-Cup'].first.row).to be_decorated
        expect(described_class.for_team(team.id, :male)).to eq({})
      end
    end

    it 'counts teams' do
      expect(round.team_count).to eq 3
      expect(cup.team_count).to eq 3
    end
  end
end
