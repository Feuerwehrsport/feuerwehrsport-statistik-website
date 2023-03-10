# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Places' do
  let!(:competition) { create(:competition) }
  let(:place) { competition.place }

  describe 'GET index' do
    it 'assigns collection' do
      get '/places'
      expect(response).to be_successful
      expect(controller.send(:collection).length).to eq 1
    end
  end

  describe 'GET show' do
    it 'assigns resource' do
      get "/places/#{place.id}"
      expect(response).to be_successful
      expect(controller.send(:resource)).to eq place
    end
  end
end
