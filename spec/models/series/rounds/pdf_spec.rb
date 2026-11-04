# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Series::Rounds::Pdf do
  let(:round) { create(:series_round, full_cup_count: 2) }
  let(:cup1) { create(:series_cup, round:, competition: create(:competition, date: Date.new(2016, 5, 1))) }
  let(:cup2) do
    create(:series_cup, round:, competition: create(:competition, date: Date.new(2016, 6, 1),
                                                                  place: create(:place, name: 'Warin')))
  end
  let(:la) { create(:series_team_assessment, round:, discipline: 'la', key: 'male') }
  let(:team) { create(:team) }
  let(:other_team) { create(:team, name: 'FF Other', shortcut: 'Other') }

  def build_with_tables
    instance = described_class.new(round)
    tables = []
    allow(instance.send(:prawn)).to receive(:table).and_wrap_original do |method, *args, **opts, &block|
      tables.push(args.first)
      method.call(*args, **opts, &block)
    end
    instance.unicode { instance.build }
    [instance, tables]
  end

  it 'renders empty round' do
    instance, tables = build_with_tables
    expect(instance.bytestream).to start_with('%PDF')
    expect(tables).to eq []
    expect(instance.filename).to eq 'd-cup-2016.pdf'
  end

  context 'with participations' do
    before do
      create(:series_team_participation, team_assessment: la, cup: cup1, team:, time: 2234, points: 15, rank: 1)
      create(:series_team_participation, team_assessment: la, cup: cup2, team: other_team, time: 2300, points: 10,
                                         rank: 1, points_correction: -2, points_correction_hint: 'Strafe')
    end

    it 'renders one table for every team assessment with rows' do
      instance, tables = build_with_tables
      expect(instance.bytestream).to start_with('%PDF')
      expect(tables.count).to eq 1

      table = tables.first
      expect(table.first).to eq %w[Platz Team Charlottenthal Warin Teil. Punkte]
      expect(table.drop(1).map { |line| line.values_at(0, 1, 4, 5) }).to eq [
        [1, 'Warin', 1, 15],
        [2, 'Other', 1, 8],
      ]
      expect(table[1][2]).to be_a Prawn::Table
      expect(table[1][3]).to eq ''
    end
  end
end
