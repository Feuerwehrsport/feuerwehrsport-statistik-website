# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Series::Assessments::Pdf do
  let(:assessment) { create(:series_person_assessment) }
  let(:pdf) { described_class.build(assessment) }

  describe '.build' do
    it 'returns bytestream' do
      expect(pdf.bytestream).not_to be_nil
    end
  end

  context 'with participations' do
    let(:round) { create(:series_round, full_cup_count: 3) }
    let(:assessment) { create(:series_person_assessment, round:, discipline: 'hb', key: 'female') }
    let(:cup1) { create(:series_cup, round:, competition: create(:competition, date: Date.new(2016, 5, 1))) }
    let(:cup2) do
      create(:series_cup, round:, competition: create(:competition, date: Date.new(2016, 6, 1),
                                                                    place: create(:place, name: 'Warin')))
    end
    let(:anna) { create(:person, :female, first_name: 'Anna', last_name: 'Ahrens') }
    let(:berta) { create(:person, :female, first_name: 'Berta', last_name: 'Bauer') }

    before do
      create(:series_person_participation, person_assessment: assessment, cup: cup1, person: anna, time: 1750,
                                           points: 10, rank: 1)
      create(:series_person_participation, person_assessment: assessment, cup: cup2, person: anna, time: 1800,
                                           points: 8, rank: 2, points_correction: 1)
      create(:series_person_participation, person_assessment: assessment, cup: cup2, person: berta, time: 1700,
                                           points: 10, rank: 1)
    end

    it 'renders table with all rows' do
      instance = described_class.new(assessment)
      lines = nil
      allow(instance.send(:prawn)).to receive(:table).and_wrap_original do |method, *args, **opts, &block|
        lines = args.first
        method.call(*args, **opts, &block)
      end
      instance.unicode { instance.build }

      expect(instance.bytestream).to start_with('%PDF')
      expect(lines).to eq [
        %w[Platz Name Charlottenthal Warin Bestzeit Summe Teil. Punkte],
        [1, 'Bauer, Berta', '', '17,00 (10)', '17,00', '17,00', 1, 10],
        [2, 'Ahrens, Anna', '17,50 (10)', '18,00 (8+1)', '17,50', '35,50', 2, 19],
      ]
      expect(instance.filename).to eq 'hindernisbahn-frauen.pdf'
    end
  end
end
