# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::People' do
  let!(:nation) { create(:nation) }
  let(:person) { create(:person, :with_best_scores) }

  describe 'GET index' do
    before { person }

    let!(:female_person) { create(:person, :female, :with_best_scores) }

    it 'returns people' do
      get '/api/people'
      expect_json_response
      expect(json_body[:people].count).to eq 2
      expect(json_body[:people]).to contain_exactly({
                                                      first_name: 'Alfred',
                                                      gender: 'male',
                                                      id: person.id,
                                                      last_name: 'Meier',
                                                      nation_id: 1,
                                                      gender_translated: 'männlich',
                                                    }, {
                                                      first_name: 'Johanna',
                                                      gender: 'female',
                                                      id: female_person.id,
                                                      last_name: 'Meyer',
                                                      nation_id: 1,
                                                      gender_translated: 'weiblich',
                                                    })
    end

    it 'returns only gendered people' do
      get '/api/people', params: { gender: :male }
      expect_json_response
      expect(json_body[:people].count).to eq 1
      expect(json_body[:people].first).to eq(
        first_name: 'Alfred',
        gender: 'male',
        id: person.id,
        last_name: 'Meier',
        nation_id: 1,
        gender_translated: 'männlich',
      )
    end

    context 'when extended' do
      it 'returns extended people' do
        get '/api/people', params: { extended: 1 }
        expect_json_response
        expect(json_body[:people].count).to eq 2
        expect(json_body[:people]).to contain_exactly({
                                                        first_name: 'Alfred',
                                                        gender: 'male',
                                                        id: person.id,
                                                        last_name: 'Meier',
                                                        nation_id: 1,
                                                        gender_translated: 'männlich',
                                                        best_scores: { pb: { hb: [2324, 'Name des Wettkampfes'],
                                                                             hl: nil } },
                                                      }, {
                                                        first_name: 'Johanna',
                                                        gender: 'female',
                                                        id: female_person.id,
                                                        last_name: 'Meyer',
                                                        nation_id: 1,
                                                        gender_translated: 'weiblich',
                                                        best_scores: { pb: { hb: [2324, 'Name des Wettkampfes'],
                                                                             hl: nil } },
                                                      })
      end
    end
  end
end
