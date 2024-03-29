# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Events' do
  let!(:competition) { create(:competition) }
  let(:event) { competition.event }

  describe 'GET index' do
    it 'assigns collection' do
      get '/events'
      expect(response).to be_successful
      expect(controller.send(:collection).length).to eq 1
    end
  end

  describe 'GET show' do
    it 'assigns resource' do
      get "/events/#{event.id}"
      expect(response).to be_successful
      expect(controller.send(:resource)).to eq event
    end
  end
end
