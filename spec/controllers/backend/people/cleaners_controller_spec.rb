require 'rails_helper'

RSpec.describe Backend::People::CleanersController, type: :controller, login: :sub_admin do
  describe 'GET show' do
    it 'shows list' do
      get :show
      expect(response).to be_success
    end
  end
end
