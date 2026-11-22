# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Backend::Competitions', login: :sub_admin do
  let(:place) { create(:place) }
  let(:event) { create(:event) }
  let(:score_type) { create(:score_type) }

  it_behaves_like 'a backend resource controller' do
    let(:resource_attributes) do
      {
        name: '4. Pokallauf',
        date: '2018-01-08',
        place_id: place.id,
        event_id: event.id,
        score_type_id: score_type.id,
        hint_content: 'Hinweise zum Wettkampf',
      }
    end
  end

  it 'deletes the links together with the competition' do
    competition = create(:link).linkable
    expect do
      delete "/backend/competitions/#{competition.id}"
    end.to change(Competition, :count).by(-1).and change(Link, :count).by(-1)
  end

  it 'does not delete a competition with scores and says why' do
    competition = create(:score).competition
    expect do
      delete "/backend/competitions/#{competition.id}",
             headers: { 'HTTP_REFERER' => "/backend/competitions/#{competition.id}" }
    end.not_to change(Competition, :count)
    expect(response).to redirect_to("/backend/competitions/#{competition.id}")
    follow_redirect!
    expect(response.body).to include('Kann nicht gelöscht werden, weil noch Einzelzeiten damit verbunden sind.')
  end
end
