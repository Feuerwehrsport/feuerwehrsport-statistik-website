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
end
