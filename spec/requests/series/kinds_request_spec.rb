# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Series::Kinds' do
  let!(:round) { create(:series_round) }

  describe 'GET index' do
    it 'assigns collection' do
      get '/series/kinds'
      expect(response).to be_successful
    end
  end
end
