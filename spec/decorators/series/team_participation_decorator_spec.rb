# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Series::TeamParticipationDecorator do
  let(:participation) do
    build(:series_team_participation, time: 2234, points: 10, points_correction: 0, points_correction_hint: 'Null')
  end
  let(:decorator) { participation.decorate }

  it 'formats time and points with correction' do
    expect(decorator.second_time).to eq '22,34'
    expect(decorator.points_with_correction).to eq '10+0'
    expect(decorator.second_time_with_points).to eq '<abbr title="Null">22,34 (10+0)</abbr>'
    expect(decorator.second_time_with_points(html: false)).to eq '22,34 (10+0)'
  end

  it 'shows plain points without correction' do
    participation.points_correction = nil
    participation.points_correction_hint = nil
    expect(decorator.second_time_with_points).to eq '22,34 (10)'
  end
end
