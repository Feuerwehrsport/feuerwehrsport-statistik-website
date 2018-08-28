require 'rails_helper'

RSpec.describe Backend::ImportsController, type: :controller, login: :admin do
  describe 'GET index' do
    it 'successes' do
      get :index
      expect(response).to be_success
    end
  end
end
