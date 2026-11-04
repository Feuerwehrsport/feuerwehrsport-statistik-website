# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Calculation::TeamPerson do
  let(:person) { create(:person).becomes(described_class) }

  it 'starts without counts' do
    expect(%i[hl hb gs fs la].map { |d| person.public_send(d) }).to all(be_nil)
  end

  it 'increments discipline counts' do
    person.increment(:gs)
    person.increment(:fs, 3)
    person.increment(:fs)
    expect(person.gs).to eq 1
    expect(person.fs).to eq 4
    expect(person.la).to be_nil
    expect(person.last_name).to eq 'Meier'
  end
end
