# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Series::TeamDecorator do
  let(:config) { Series::AssessmentConfig.new(key: 'female', disciplines: ['fs'], calc_participations_count: 1) }
  let(:cup) { build_stubbed(:series_cup) }
  let(:entity) { Series::Team.new(config:, team: build_stubbed(:team), team_number: 1, team_gender: 1) }
  let(:decorator) { entity.decorate }

  before do
    entity.add_participation(build(:series_team_participation, cup:, time: 2250))
    entity.add_participation(build(:series_team_participation, cup: build_stubbed(:series_cup), time: 2150))
  end

  it 'formats times' do
    expect(decorator.second_best_time).to eq '21,50'
    # only the best participation counts (calc_participations_count: 1)
    expect(decorator.second_sum_time).to eq '21,50'
  end

  it 'decorates participations for cup' do
    expect(decorator.participations_for_cup(cup).map(&:class)).to eq [Series::TeamParticipationDecorator]
  end
end
