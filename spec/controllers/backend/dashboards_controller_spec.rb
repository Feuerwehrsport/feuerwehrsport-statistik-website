# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Backend::DashboardsController do
  describe 'GET index' do
    it 'successes' do
      get :index
      expect(response).to redirect_to(new_session_path)
    end
  end
end
