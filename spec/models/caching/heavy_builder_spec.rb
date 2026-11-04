# frozen_string_literal: true

require 'rails_helper'

describe Caching::HeavyBuilder do
  let!(:person) { create(:person) }
  let!(:team) { create(:team) }
  let!(:competition) { create(:competition, date: Date.new(2017, 5, 1)) }
  let!(:current_competition) { create(:competition, name: 'Aktuell', date: Date.current) }
  let(:din_wko) { create(:group_score_type, discipline: 'la', name: 'WKO DIN-Pumpe') }
  let(:tgl_wko) { create(:group_score_type, discipline: 'la', name: 'WKO TGL-Pumpe') }

  before do
    GroupScoreType.instance_variable_set(:@din_wko, nil)
    GroupScoreType.instance_variable_set(:@tgl_wko, nil)

    create(:score, :hb, person:, team:, competition:, time: 1700)
    create(:score, :hb, person:, team:, competition: current_competition, time: 1800)
    create(:score, :hl, person:, team:, competition:, time: 1500)

    old_category = create(:group_score_category, competition:, group_score_type: din_wko)
    current_category = create(:group_score_category, competition: current_competition, group_score_type: din_wko)
    create(:group_score, team:, group_score_category: old_category, time: 2200)
    create(:group_score, team:, group_score_category: current_category, time: 2500)
    create(:group_score, team:, gender: :female, group_score_category: current_category, time: 3000)
    tgl_wko

    competition.update_column(:long_name, nil)
  end

  after do
    GroupScoreType.instance_variable_set(:@din_wko, nil)
    GroupScoreType.instance_variable_set(:@tgl_wko, nil)
  end

  it 'updates long names and best scores' do
    described_class.perform_now

    competition.reload
    expect(competition.long_name).to eq competition.decorate.to_s
    expect(competition.long_name).to be_present
    long_name = competition.long_name
    current_long_name = current_competition.reload.long_name

    expect(person.reload.best_scores).to eq(
      'pb' => { 'hl' => [1500, long_name], 'hb' => [1700, long_name], 'zk' => [3200, long_name] },
      'sb' => { 'hl' => nil, 'hb' => [1800, current_long_name], 'zk' => nil },
    )

    expect(team.reload.best_scores).to eq(
      'female' => {
        'din' => { 'pb' => [3000, current_long_name], 'sb' => [3000, current_long_name] },
        'tgl' => { 'pb' => nil, 'sb' => nil },
      },
      'male' => {
        'din' => { 'pb' => [2200, long_name], 'sb' => [2500, current_long_name] },
        'tgl' => { 'pb' => nil, 'sb' => nil },
      },
    )
  end

  it 'prefers scores of the default single discipline for people' do
    old_discipline = create(:single_discipline, :hb_female_old)
    female = create(:person, :female)
    create(:score, person: female, team:, competition:, single_discipline: old_discipline, time: 1600)

    described_class.perform_now
    expect(female.reload.best_scores['pb']['hb']).to eq [1600, competition.reload.long_name]

    hb_female = create(:single_discipline, :hb_female, default_for_male: false, default_for_female: true)
    create(:score, person: female, team:, competition:, single_discipline: hb_female, time: 1900)
    SingleDiscipline.instance_variable_set(:@single_disciplines, nil)
    described_class.perform_now
    expect(female.reload.best_scores['pb']['hb']).to eq [1900, competition.long_name]
  end

  it 'updates long name after save' do
    competition.update!(name: 'Neuer Name')
    expect(competition.reload.long_name).to include('Neuer Name')
  end
end
