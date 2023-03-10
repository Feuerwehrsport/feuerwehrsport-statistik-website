# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::Series::Rounds' do
  let(:round) { create(:series_round) }
  let(:attributes) do
    { name: 'Cup', slug: 'cup', year: 2017, official: true, aggregate_type: 'LaCup', full_cup_count: 4 }
  end

  describe 'GET show' do
    it 'returns round' do
      get "/api/series/rounds/#{round.id}"
      expect_json_response
      expect(json_body[:series_round]).to eq(
        aggregate_type: 'DCup',
        id: round.id,
        name: 'D-Cup',
        year: 2016,
        full_cup_count: 4,
        official: false,
      )
    end
  end

  describe 'GET index' do
    before { round }

    it 'returns rounds' do
      get '/api/series/rounds'
      expect_json_response
      expect(json_body[:series_rounds].first).to eq(
        aggregate_type: 'DCup',
        id: round.id,
        name: 'D-Cup',
        year: 2016,
        full_cup_count: 4,
        official: false,
      )
    end
  end
end
