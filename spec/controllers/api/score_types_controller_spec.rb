# frozen_string_literal: true

require 'rails_helper'

RSpec.describe API::ScoreTypesController, type: :controller do
  let!(:score_type) { create(:score_type) }

  describe 'GET index' do
    it 'returns score_types' do
      get :index
      expect_json_response
      expect(json_body[:score_types].first).to eq(
        id: score_type.id,
        people: 10,
        run: 8,
        score: 6,
      )
    end
  end
end
