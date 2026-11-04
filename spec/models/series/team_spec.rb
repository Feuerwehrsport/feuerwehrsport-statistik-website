# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Series::Team do
  let(:round) { create(:series_round, full_cup_count: 3) }
  let(:cups) do
    Array.new(3) do |i|
      create(:series_cup, round:, competition: create(:competition, date: Date.new(2016, 5, i + 1)))
    end
  end
  let(:team_record) { create(:team) }
  let(:la) { create(:series_team_assessment, round:, discipline: 'la', key: 'female') }
  let(:fs) { create(:series_team_assessment, round:, discipline: 'fs', key: 'female') }
  let(:config_attributes) { { key: 'female', disciplines: ['la'], calc_participations_count: 2 } }
  let(:config) do
    Series::AssessmentConfig.new(config_attributes).tap { |c| c.round = round }
  end
  let(:team) do
    described_class.new(config:, team: team_record, team_number: 1, team_gender: 0, round:)
  end

  def participation(cup, assessment, time:, points:, rank: 1)
    build(:series_team_participation, cup:, team_assessment: assessment, team: team_record, time:, points:, rank:)
  end

  it 'delegates team_id' do
    expect(team.team_id).to eq team_record.id
  end

  context 'with participations in two of three cups' do
    let!(:p1) { participation(cups[0], la, time: 2400, points: 10) }
    let!(:p2) { participation(cups[1], la, time: 2200, points: 15) }

    before do
      team.add_participation(p1)
      team.add_participation(p2)
    end

    it 'sums points of ordered participations' do
      expect(team.count).to eq 2
      expect(team.points).to eq 25
      expect(team.points_for_cup(cups[0])).to eq 10
      expect(team.points_for_cup(cups[2])).to eq 0
      expect(team.participations_for_cup(cups[2])).to eq []
    end

    context 'with penalty points' do
      let(:config_attributes) do
        { key: 'female', disciplines: ['la'], calc_participations_count: 3, penalty_points: -5 }
      end

      it 'adds penalty points for every missing cup' do
        cups # all three cups exist
        expect(team.points).to eq 20
      end
    end

    it 'calculates best and sum time' do
      expect(team.best_time).to eq 2200
      expect(team.sum_time).to eq 4600
    end
  end

  context 'with participations in multiple disciplines' do
    let!(:la_part) { participation(cups[0], la, time: 2400, points: 10) }
    let!(:fs_part) { participation(cups[0], fs, time: 5000, points: 8) }

    before do
      team.add_participation(fs_part)
      team.add_participation(la_part)
    end

    it 'returns participations of cup sorted by assessment' do
      expect(team.participations_for_cup(cups[0])).to eq [la_part, fs_part]
    end

    it 'sums all participations of cup' do
      expect(team.points_for_cup(cups[0])).to eq 18
    end

    context 'when config contains la' do
      let(:config_attributes) { { key: 'female', disciplines: %w[la fs], calc_participations_count: 2 } }
      let!(:fs_part) { participation(cups[0], fs, time: 2000, points: 8) }

      it 'uses only la times for best time' do
        expect(team.best_time).to eq 2400
      end
    end

    context 'when config does not contain la' do
      let(:config_attributes) { { key: 'female', disciplines: %w[fs gs], calc_participations_count: 2 } }
      let!(:fs_part) { participation(cups[0], fs, time: 2000, points: 8) }

      it 'uses all times for best time' do
        expect(team.best_time).to eq 2000
      end
    end
  end
end
