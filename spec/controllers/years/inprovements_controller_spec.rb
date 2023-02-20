# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Years::InprovementsController, type: :controller do
  let!(:score) { create(:score, :double) }

  describe 'GET index' do
    it 'assigns collection' do
      get :index, params: { year_id: score.competition.date.year }
      expect(assigns(:disciplines).length).to eq 4
    end
  end

  describe 'GET show' do
    it 'assigns collection' do
      get :show, params: { year_id: score.competition.date.year, id: score.team_id }
      expect(assigns(:disciplines).length).to eq 4
    end
  end
end
