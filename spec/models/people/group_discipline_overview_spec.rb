# frozen_string_literal: true

require 'rails_helper'

RSpec.describe People::GroupDisciplineOverview do
  let(:person) { create(:person) }
  let(:mate) { create(:person, first_name: 'Bernd') }
  let(:other_mate) { create(:person, first_name: 'Carl') }
  let(:la) { create(:group_score_type) }
  let(:competition2017) { create(:competition) }
  let(:competition2016) { create(:competition, date: Date.parse('2016-05-01')) }
  let(:category2017) { create(:group_score_category, group_score_type: la, competition: competition2017) }
  let(:category2016) { create(:group_score_category, group_score_type: la, competition: competition2016) }

  let!(:run1) { create_run(category2017, 2500, [person, mate]) }
  let!(:run2) { create_run(category2017, 2300, [person, mate, other_mate]) }
  let!(:run3) { create_run(category2016, 2600, [mate, person]) }
  let!(:run4) { create_run(category2016, Firesport::INVALID_TIME, [person]) }

  def create_run(category, time, people)
    group_score = create(:group_score, group_score_category: category, time:)
    people.each_with_index do |participant, index|
      create(:person_participation, person: participant, group_score:, position: index + 1)
    end
    group_score
  end

  it 'returns only disciplines with scores' do
    expect(described_class.for(person).map(&:discipline)).to eq [:la]
  end

  describe 'statistics' do
    let(:overview) { described_class.new(person, :la) }

    it 'calculates count, best and average' do
      expect(overview).not_to be_blank
      expect(overview.count).to eq 4
      expect(overview.valid_scores.map(&:time)).to contain_exactly(2500, 2300, 2600)
      expect(overview.best_time).to eq '23,00'
      expect(overview.average_time).to eq '24,66'
      expect(overview.scores_decorated).to all(be_decorated)
    end

    it 'returns chart scores sorted by date' do
      expect(overview.chart_scores.map(&:time)).to eq [2600, 2300]
    end

    it 'collects team mates with common runs' do
      team_mates = overview.team_mates.to_h { |mate| [mate.person.object, mate.scores.map(&:object)] }
      expect(team_mates.keys).to contain_exactly(mate, other_mate)
      expect(team_mates[mate]).to contain_exactly(run1, run2, run3)
      expect(team_mates[other_mate]).to eq [run2]
    end
  end

  it 'is blank for other disciplines' do
    overview = described_class.new(person, :gs)
    expect(overview).to be_blank
    expect(overview.team_mates).to eq []
  end
end
