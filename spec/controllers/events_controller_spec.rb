require 'rails_helper'

RSpec.describe EventsController, type: :controller do
  let!(:competition) { create(:competition) }
  let(:event) { competition.event }

  describe 'GET index' do
    it 'assigns collection' do
      get :index
      expect(response).to be_success
      expect(controller.send(:collection).length).to eq 1
    end
  end

  describe 'GET show' do
    it 'assigns resource' do
      get :show, id: event.id
      expect(response).to be_success
      expect(controller.send(:resource)).to eq event
    end
  end
end
