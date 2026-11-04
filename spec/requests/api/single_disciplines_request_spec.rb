# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::SingleDisciplines' do
  let!(:hb_male) { create(:single_discipline, :hb_male) }
  let!(:hl_male) { create(:single_discipline, :hl_male) }
  let!(:hb_female) { create(:single_discipline, :hb_female) }

  describe 'GET index' do
    it 'returns all single disciplines ordered by name' do
      get '/api/single_disciplines'
      expect_json_response
      expect(json_body[:success]).to be true
      expect(json_body[:single_disciplines].pluck(:id)).to eq [hb_female.id, hb_male.id, hl_male.id]
      expect(json_body[:single_disciplines].first).to include(
        id: 4,
        key: 'hb',
        name: '100m-Hindernisbahn (Frauen)',
        short_name: '100m-Hindernisbahn',
      )
    end

    it 'filters by key' do
      get '/api/single_disciplines', params: { key: 'hl' }
      expect_json_response
      expect(json_body[:single_disciplines].pluck(:id)).to eq [hl_male.id]
    end
  end
end
