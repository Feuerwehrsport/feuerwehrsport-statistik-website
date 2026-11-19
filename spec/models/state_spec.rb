# frozen_string_literal: true

require 'rails_helper'

RSpec.describe State do
  describe '.from_place' do
    it 'maps country and state of a nominatim place' do
      expect(described_class.from_place('de', 'Sachsen')).to eq 'SN'
      expect(described_class.from_place('de', 'Bayern')).to eq 'DE'
      expect(described_class.from_place('cz', 'Liberecký kraj')).to eq 'CZ'
      expect(described_class.from_place('by', 'Minsk')).to eq 'BY'
      expect(described_class.from_place('fr', 'Bretagne')).to be_nil
      expect(described_class.from_place(nil, nil)).to be_nil
    end
  end
end
