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

  it 'returns not found for methods outside of AssociationSelect' do
    get '/association_select/instance_variable_get', params: { q: '@ability' }
    expect(response).to have_http_status(:not_found)
  end

  it 'ignores a limit param' do
    create_list(:place, 11)
    get '/association_select/place', params: { limit: 1000 }
    expect(response.parsed_body['payload']['results'].size).to eq 10
  end
end
