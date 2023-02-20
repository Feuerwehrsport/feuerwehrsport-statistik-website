# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Backend::ChangeRequestsController, type: :controller do
  describe 'GET index' do
    it 'successes', login: :sub_admin do
      get :index
      expect(response).to be_successful
    end
  end
end
