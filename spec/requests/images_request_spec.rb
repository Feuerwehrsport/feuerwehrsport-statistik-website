# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Images' do
  let(:person_participation) { create(:person_participation) }

  describe 'GET la_positions' do
    it 'sends image' do
      get "/images/person_la_positions/#{person_participation.person_id}"
      expect(response).to be_successful
      expect(response.header['Content-Type']).to eq 'image/png'
    end
  end
end
