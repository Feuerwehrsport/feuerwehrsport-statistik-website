# frozen_string_literal: true

require 'rails_helper'

RSpec.describe API::PersonSpellingsController, type: :controller do
  let!(:person_spelling) { create(:person_spelling) }

  describe 'GET index' do
    it 'returns person_spellings' do
      get :index
      expect_json_response
      expect(json_body[:person_spellings].first).to eq(
        person_id: person_spelling.person_id,
        first_name: 'Alfredo',
        last_name: 'Mayer',
        gender: 'male',
        gender_translated: 'männlich',
        official: false,
      )
      expect(json_body[:person_spellings].count).to eq 1
    end
  end
end
