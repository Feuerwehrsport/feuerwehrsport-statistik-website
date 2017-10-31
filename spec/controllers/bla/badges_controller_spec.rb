require 'rails_helper'

RSpec.describe BLA::BadgesController, type: :controller do
  let!(:badge) { create(:bla_badge) }

  describe 'GET index' do
    it 'assigns collection' do
      get :index
      expect(response).to be_success
      expect(controller.send(:collection).length).to eq 1
    end
  end
end
