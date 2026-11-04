# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'AssociationSelect', login: :sub_admin do
  let!(:place) { create(:place) }

  it 'returns matching records for allowed associations' do
    get '/association_select/place', params: { q: place.name }
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body['association']).to eq 'place'
    expect(response.parsed_body['payload']['results'].to_s).to include(place.name)
  end

  it 'returns not found for unknown associations' do
    get '/association_select/destroy_all'
    expect(response).to have_http_status(:not_found)
  end
end
