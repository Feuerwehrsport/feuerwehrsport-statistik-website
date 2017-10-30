require 'rails_helper'

RSpec.describe Series::RoundsController, type: :controller do
  let!(:round) { create(:series_round) }

  describe 'GET index' do
    it 'assigns collection' do
      get :index
      expect(assigns(:rounds).keys).to eq ['D-Cup']
    end
  end

  describe 'GET show' do
    it 'assigns resource' do
      get :show, id: round.id
      expect(controller.send(:resource)).to be_a Series::Round
    end
  end
end
