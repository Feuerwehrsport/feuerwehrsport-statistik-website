# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Backend::Links', login: :sub_admin do
  let(:competition) { create(:competition) }

  it_behaves_like 'a backend resource controller' do
    let(:resource_attributes) do
      {
        label: 'Ergebnisse',
        linkable_type: 'Competition',
        linkable_id: competition.id,
        url: 'http://foobar.de',
      }
    end
  end
end
