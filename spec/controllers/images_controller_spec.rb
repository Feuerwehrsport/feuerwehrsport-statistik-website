require 'rails_helper'

RSpec.describe ImagesController, type: :controller do
  let(:person_participation) { create(:person_participation) }

  describe 'GET la_positions' do
    it 'sends image' do
      get :la_positions, params: { person_id: person_participation.person_id }
      expect(response).to be_successful
      expect(response.header['Content-Type']).to eq 'image/png'
    end
  end
end
