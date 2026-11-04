# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Series::TeamAssessmentDecorator do
  let(:round) { create(:series_round) }
  let(:assessment) { create(:series_team_assessment, round:) }
  let(:decorator) { assessment.decorate }

  it 'builds names' do
    expect(decorator.to_s).to eq 'Löschangriff nass - Frauen'
    expect(decorator.page_title).to eq "#{round.decorate} #{decorator} - Wettkampfserie"
  end

  it 'decorates rows' do
    create(:series_team_participation, team_assessment: assessment, cup: create(:series_cup, round:))
    expect(decorator.rows.map(&:class)).to eq [Series::TeamDecorator]
  end
end
