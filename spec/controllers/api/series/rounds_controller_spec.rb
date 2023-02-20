# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::Series::RoundsController do
  let(:round) { create(:series_round) }
  let(:attributes) do
    { name: 'Cup', slug: 'cup', year: 2017, official: true, aggregate_type: 'LaCup', full_cup_count: 4 }
  end

  describe 'POST create' do
    let(:r) { -> { post :create, params: { series_round: attributes } } }

    it 'creates new round', login: :admin do
      expect do
        r.call
        expect_api_login_response(created_id: Series::Round.last.id)
      end.to change(Series::Round, :count).by(1)
      expect_change_log(after: { year: 2017 }, log: 'create-series-round')
    end

    it_behaves_like 'api user get permission error'
    it_behaves_like 'sub_admin get permission error'
  end

  describe 'PUT update' do
    let(:r) { -> { put :update, params: { id: round.id, series_round: attributes } } }

    it 'update round', login: :admin do
      r.call
      expect_json_response
      expect(Series::Round.first.official).to be true
      expect_change_log(before: { year: 2016 }, after: { year: 2017 }, log: 'update-series-round')
    end

    it_behaves_like 'api user get permission error'
    it_behaves_like 'sub_admin get permission error'
  end

  describe 'GET show' do
    it 'returns round' do
      get :show, params: { id: round.id }
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
      get :index
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
