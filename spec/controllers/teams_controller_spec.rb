require 'rails_helper'

RSpec.describe TeamsController, type: :controller do
  let!(:team) { create(:team) }

  describe 'GET index' do
    it 'assigns collection' do
      get :index
      expect(response).to be_success
      expect(assigns(:charts)).to be_instance_of(Chart::TeamOverview)
    end
  end

  describe 'GET show' do
    it 'assigns resource' do
      get :show, params: { id: team.id }
      expect(response).to be_success
      expect(controller.send(:resource)).to eq team
    end
  end
end
