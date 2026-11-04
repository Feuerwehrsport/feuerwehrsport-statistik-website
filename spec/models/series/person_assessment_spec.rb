# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Series::PersonAssessment do
  let(:round) { create(:series_round, full_cup_count: 2) }
  let(:assessment) { create(:series_person_assessment, round:, discipline: 'hb', key: 'female') }
  let(:person) { create(:person, :female) }
  let(:other_person) { create(:person, :female, first_name: 'Other') }
  let(:cup) { create(:series_cup, round:) }

  before do
    create(:series_person_participation, person_assessment: assessment, cup:, person:, points: 15, rank: 1)
    create(:series_person_participation, person_assessment: assessment, cup:, person: other_person, points: 14,
                                         time: 2000, rank: 2)
  end

  it 'uses config of round by key' do
    expect(assessment.config).to have_attributes(key: 'female', entity_key: :person, round:)
    expect(assessment.name).to eq 'Frauen'
    expect(assessment.rows.map(&:person)).to eq [person, other_person]
  end

  describe '.with_person' do
    it 'returns assessments of person' do
      create(:series_person_assessment, round:, discipline: 'hl', key: 'female')
      expect(described_class.with_person(person.id)).to eq [assessment]
    end
  end

  describe '.for' do
    it 'returns structs grouped by kind name and year' do
      result = described_class.for(person.id)
      expect(result.keys).to eq ['D-Cup']
      expect(result['D-Cup'].keys).to eq [2016]

      struct = result['D-Cup'][2016].first
      expect(struct.assessment).to eq assessment
      expect(struct.round).to eq round
      expect(struct.cups).to eq [cup]
      expect(struct.row.person_id).to eq person.id
      expect(struct.row.rank).to eq 1
    end

    context 'when person has no rank' do
      let(:round) { create(:series_round, full_cup_count: 1) }

      it 'skips assessment' do
        # round is complete and min_participations_count is 2
        expect(described_class.for(person.id)).to eq({})
      end
    end
  end
end
