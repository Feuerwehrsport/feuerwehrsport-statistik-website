# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::Nations' do
  let!(:nation) { create(:nation) }

  describe 'GET show' do
    it 'returns nation' do
      get "/api/nations/#{nation.id}"
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
      get '/api/nations'
      expect_json_response
      expect(json_body[:nations].first).to eq(id: 1, iso: 'de', name: 'Deutschland')
    end
  end
end
