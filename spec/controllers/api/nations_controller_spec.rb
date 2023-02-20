# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::NationsController do
  let!(:nation) { create(:nation) }

  describe 'GET show' do
    it 'returns nation' do
      get :show, params: { id: 1 }
      expect_json_response
      expect(json_body[:nation]).to eq(
        id: 1,
        name: 'Deutschland',
        iso: 'de',
      )
    end
  end

  describe 'GET index' do
    it 'returns nations' do
      get :index
      expect_json_response
      expect(json_body[:nations].first).to eq(id: 1, iso: 'de', name: 'Deutschland')
    end
  end
end
