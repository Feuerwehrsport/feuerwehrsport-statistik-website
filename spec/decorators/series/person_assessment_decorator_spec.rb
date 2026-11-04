# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Series::PersonAssessmentDecorator do
  let(:round) { create(:series_round) }
  let(:assessment) { create(:series_person_assessment, round:, discipline: 'hb', key: 'female') }
  let(:decorator) { assessment.decorate }

  it 'builds names' do
    expect(decorator.to_s).to eq 'Hindernisbahn - Frauen'
    expect(decorator.page_title).to eq 'D-Cup 2016 Hindernisbahn - Frauen - Wettkampfserie'
  end

  it 'decorates rows' do
    create(:series_person_participation, person_assessment: assessment, cup: create(:series_cup, round:))
    expect(decorator.rows.map(&:class)).to eq [Series::PersonDecorator]
  end
end
