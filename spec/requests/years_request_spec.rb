# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Years' do
  let!(:competition) { create(:competition) }
  let!(:score) { create(:score, :double) }
  let!(:group_score) { create(:group_score, :double) }

  describe 'GET index' do
    it 'assigns collection' do
      get '/years'
      expect(response).to be_successful
      expect(controller.send(:collection).length).to eq 1
    end
  end

  describe 'GET show' do
    it 'assigns resource' do
      get "/years/#{competition.date.year}"
      expect(response).to be_successful
      expect(controller.send(:resource).year).to eq Year.first.year
    end
  end

  describe 'GET best_performance' do
    it 'assigns resource' do
      get "/years/#{competition.date.year}/best_performance"
      expect(response).to be_successful
      expect(controller.send(:resource).year).to eq Year.first.year
    end
  end

  describe 'GET best_scores' do
    it 'assigns resource' do
      get "/years/#{competition.date.year}/best_scores"
      expect(response).to be_successful
      expect(controller.send(:resource).year).to eq Year.first.year
    end
  end
end
