# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Registrations::Teams::Pdf, type: :model do
  let(:competition) { create(:registrations_competition) }
  let(:team) { create(:registrations_team, competition: competition) }
  let(:pdf) { described_class.build(team) }

  describe '.build' do
    it 'returns bytestream' do
      expect(pdf.bytestream).not_to be_nil
    end
  end
end
