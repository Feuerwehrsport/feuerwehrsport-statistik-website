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
end
