# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Teams' do
  let!(:team) { create(:team) }

  describe 'GET index' do
    it 'assigns collection' do
      get '/teams'
      expect(response).to be_successful
    end
  end

  describe 'GET show' do
    it 'assigns resource' do
      get "/teams/#{team.id}"
      expect(response).to be_successful
      expect(controller.send(:resource)).to eq team
    end
  end
end
