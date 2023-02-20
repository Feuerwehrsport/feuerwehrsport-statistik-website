# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Backend::ImportsController, login: :admin do
  describe 'GET index' do
    it 'successes' do
      get :index
      expect(response).to be_successful
    end
  end
end
