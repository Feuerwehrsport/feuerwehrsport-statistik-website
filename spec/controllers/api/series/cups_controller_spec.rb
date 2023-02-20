# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::Series::CupsController do
  let!(:cup) { create(:series_cup) }

  describe 'GET index' do
    it 'returns cups' do
      get :index
      expect_json_response
      expect(json_body[:series_cups].first).to eq(
        competition_id: cup.competition_id,
        date: '2017-05-01',
        id: cup.id,
        place: 'Charlottenthal',
        round_id: cup.round_id,
      )
    end
  end
end
