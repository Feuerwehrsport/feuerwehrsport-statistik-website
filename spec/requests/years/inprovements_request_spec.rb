# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Years::Inprovements' do
  let!(:score) { create(:score, :double) }

  describe 'GET index' do
    it 'assigns collection' do
      get "/years/#{score.competition.date.year}/inprovements"
      expect(controller.instance_variable_get(:@disciplines).length).to eq 0
      expect(response).to be_successful
    end
  end

  describe 'GET show' do
    it 'assigns collection' do
      get "/years/#{score.competition.date.year}/inprovements/#{score.team_id}"
      expect(controller.instance_variable_get(:@disciplines).length).to eq 0
      expect(response).to be_successful
    end
  end
end
