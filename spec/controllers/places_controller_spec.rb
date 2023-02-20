# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PlacesController, type: :controller do
  let!(:competition) { create(:competition) }
  let(:place) { competition.place }

  describe 'GET index' do
    it 'assigns collection' do
      get :index
      expect(response).to be_successful
      expect(controller.send(:collection).length).to eq 1
    end
  end

  describe 'GET show' do
    it 'assigns resource' do
      get :show, params: { id: place.id }
      expect(response).to be_successful
      expect(controller.send(:resource)).to eq place
    end
  end
end
