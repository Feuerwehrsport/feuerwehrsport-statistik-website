# frozen_string_literal: true

require 'rails_helper'
require_relative 'serializer_helper'

RSpec.describe PersonSerializer do
  include SerializerSpecHelper

  let(:person) { create(:person, :with_best_scores) }
  let(:base_hash) do
    { id: person.id, last_name: 'Meier', first_name: 'Alfred', gender: 'male', nation_id: 1,
      gender_translated: 'männlich' }
  end

  it 'serializes person' do
    expect(api_json(person)).to eq base_hash
  end

  describe ExtendedPersonSerializer do
    it 'adds best scores' do
      expect(serializer_json(described_class, person)).to eq base_hash.merge(
        best_scores: { pb: { hb: [2324, 'Name des Wettkampfes'], hl: nil } },
      )
    end
  end

  describe SuggestionPersonSerializer do
    it 'adds team shortcuts' do
      create(:score, person:)
      expect(serializer_json(described_class, person)).to eq(
        id: person.id, last_name: 'Meier', first_name: 'Alfred', gender: 'male', gender_translated: 'männlich',
        teams: ['Warin']
      )
    end
  end

  describe PersonSpellingSerializer do
    it 'serializes person spelling' do
      spelling = create(:person_spelling, person:)
      expect(api_json(spelling)).to eq(
        person_id: person.id, first_name: 'Alfredo', last_name: 'Mayer', gender: 'male', official: false,
        gender_translated: 'männlich'
      )
    end
  end
end
