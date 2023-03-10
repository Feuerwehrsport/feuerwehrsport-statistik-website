# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Backend::Appointments', login: :sub_admin do
  let(:place) { create(:place) }
  let(:event) { create(:event) }

  it_behaves_like 'a backend resource controller' do
    let(:resource_attributes) do
      {
        name: 'Termin',
        description: 'Hinweis zum Wettkampf',
        dated_at: '2018-01-01',
        place_id: place.id,
        event_id: event.id,
        disciplines: 'hb,hl',
      }
    end
  end
end
