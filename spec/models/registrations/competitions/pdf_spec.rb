# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Registrations::Competitions::Pdf do
  let(:competition) { create(:registrations_competition) }
  let(:pdf) { described_class.build(competition, Ability.new(competition.admin_user, nil)) }

  describe '.build' do
    it 'returns bytestream' do
      expect(pdf.bytestream).not_to be_nil
    end
  end
end
