# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Contributions::People', login: :api do
  let!(:nation) { create(:nation) }
  let(:params) { { person: { first_name: 'Anna', last_name: 'Meier', gender: 'female', nation_id: nation.id } } }

  it 'shows the form' do
    get '/contributions/people/new'
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Person hinzufügen', nation.name)
  end

  it 'creates a person with change log' do
    expect { post '/contributions/people', params: }.to change(Person, :count).by(1)
    expect(response.body).to include('Anna Meier wurde gespeichert')
    expect(ChangeLog.last).to have_attributes(action: 'create-person', api_user: login_user)
  end

  it 'shows errors' do
    expect { post '/contributions/people', params: { person: { first_name: '' } } }.not_to change(Person, :count)
    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include('muss ausgefüllt werden')
  end
end
