# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Calculation::TeamCompetition do
  let(:competition) { create(:competition).becomes(described_class) }

  it 'starts without counts' do
    expect(%i[hl hb gs fs la].map { |d| competition.public_send(d) }).to all(be_nil)
  end

  it 'increments discipline counts' do
    competition.increment(:hl)
    competition.increment(:hl)
    competition.increment(:la, 5)
    expect(competition.hl).to eq 2
    expect(competition.la).to eq 5
    expect(competition.hb).to be_nil
    expect(competition.name).to eq 'Erster Lauf'
  end
end
