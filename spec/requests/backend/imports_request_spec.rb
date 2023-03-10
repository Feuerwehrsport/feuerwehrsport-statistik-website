# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Backend::Imports', login: :admin do
  describe 'GET index' do
    it 'successes' do
      get '/backend/imports'
      expect(response).to be_successful
    end
  end
end
