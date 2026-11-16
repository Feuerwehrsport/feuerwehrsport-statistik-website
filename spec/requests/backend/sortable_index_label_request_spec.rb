# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sortable index labels', login: :admin do
  it 'keeps query params and links only to the local path' do
    create(:place)
    get '/backend/places', params: { host: 'evil.example', order: 'name_asc' }
    expect(response).to be_successful
    expect(response.body).not_to include('evil.example/')
    expect(response.body).to include(ERB::Util.html_escape('/backend/places?host=evil.example&order=name_desc'))
  end
end
