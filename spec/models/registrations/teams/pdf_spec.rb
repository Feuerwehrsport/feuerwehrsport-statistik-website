# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Registrations::Teams::Pdf do
  let(:admin_user) { create(:admin_user) }
  let(:team) { create(:registrations_team, admin_user:) }
  let(:pdf) { described_class.build(team) }

  describe '.build' do
    it 'returns bytestream' do
      expect(pdf.bytestream).not_to be_nil
    end
  end
end
