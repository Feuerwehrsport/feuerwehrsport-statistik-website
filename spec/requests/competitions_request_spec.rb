# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Competitions' do
  let!(:score) { create(:score) }

  describe 'GET index' do
    it 'assigns collection' do
      get '/competitions'
      expect(response).to be_successful
      expect(controller.send(:collection).count).to eq 1
      expect(controller.instance_variable_get(:@chart)).to be_instance_of(Chart::CompetitionsScoreOverview)
      expect(controller.instance_variable_get(:@competitions_discipline_overview).count).to eq 1
    end
  end

  describe 'GET show' do
    it 'assigns resource' do
      get "/competitions/#{score.competition.id}"
      expect(response).to be_successful
      expect(controller.send(:resource)).to eq score.competition
      expect(controller.instance_variable_get(:@calc)).to be_instance_of Calculation::Competition
    end
  end
end
