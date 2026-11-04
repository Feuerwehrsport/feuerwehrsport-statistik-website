# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Series::PersonDecorator do
  let(:config) { Series::AssessmentConfig.new(key: 'female', calc_participations_count: 2) }
  let(:cup) { build_stubbed(:series_cup) }
  let(:participation) { build(:series_person_participation, cup:, time: 1750) }
  let(:entity) { Series::Person.new(config:, person: build_stubbed(:person)) }
  let(:decorator) { entity.decorate }

  before do
    entity.add_participation(participation)
    entity.add_participation(build(:series_person_participation, cup: build_stubbed(:series_cup), time: 1850))
  end

  it 'formats times' do
    expect(decorator.second_best_time).to eq '17,50'
    expect(decorator.second_sum_time).to eq '36,00'
  end

  it 'decorates participation for cup' do
    expect(decorator.participation_for_cup(cup)).to be_a Series::PersonParticipationDecorator
    expect(decorator.participation_for_cup(build_stubbed(:series_cup))).to be_nil
  end
end
