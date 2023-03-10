# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Backend::ChangeRequests' do
  describe 'GET index' do
    it 'successes', login: :sub_admin do
      get '/backend/change_requests'
      expect(response).to be_successful
    end
  end
end
