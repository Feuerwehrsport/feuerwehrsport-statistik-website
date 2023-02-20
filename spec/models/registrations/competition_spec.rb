# frozen_string_literal: true

require 'rails_helper'

describe Registrations::Competition do
  it 'destroys old entries automaticly' do
    Timecop.freeze(150.days.ago) do
      create(:registrations_competition)
    end
    expect(described_class.count).to eq 1
    create(:registrations_competition)
    expect(described_class.count).to eq 1
  end
end
