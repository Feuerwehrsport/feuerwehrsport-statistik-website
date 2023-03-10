# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Backend::People::Cleaners', login: :sub_admin do
  describe 'GET show' do
    it 'shows list' do
      get '/backend/people/cleaner'
      expect(response).to be_successful
    end
  end
end
