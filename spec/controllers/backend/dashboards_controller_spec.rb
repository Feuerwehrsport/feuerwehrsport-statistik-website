require 'rails_helper'

RSpec.describe Backend::DashboardsController, type: :controller do
  describe 'GET index' do
    it 'successes' do
      get :index
      expect(response).to be_success
    end
  end
end
