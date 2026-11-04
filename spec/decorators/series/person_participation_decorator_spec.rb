# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Series::PersonParticipationDecorator do
  let(:participation) { build(:series_person_participation, time: 1899, points: 15) }
  let(:decorator) { participation.decorate }

  it 'formats time' do
    expect(decorator.second_time).to eq '18,99'
    expect(build(:series_person_participation, time: Firesport::INVALID_TIME).decorate.second_time).to eq 'D'
  end

  context 'without correction' do
    it 'shows points' do
      expect(decorator.points_with_correction).to eq 15
      expect(decorator.second_time_with_points).to eq '18,99 (15)'
    end
  end

  context 'with positive correction' do
    let(:participation) do
      build(:series_person_participation, time: 1899, points: 15, points_correction: 2,
                                          points_correction_hint: 'Bonus')
    end

    it 'shows correction with hint' do
      expect(decorator.points_with_correction).to eq '15+2'
      expect(decorator.second_time_with_points).to eq '<abbr title="Bonus">18,99 (15+2)</abbr>'
      expect(decorator.second_time_with_points(html: false)).to eq '18,99 (15+2)'
    end
  end

  context 'with negative correction without hint' do
    let(:participation) { build(:series_person_participation, time: 1899, points: 15, points_correction: -3) }

    it 'shows correction without abbr' do
      expect(decorator.points_with_correction).to eq '15-3'
      expect(decorator.second_time_with_points).to eq '18,99 (15-3)'
    end
  end
end
