# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Backend::TeamsController, type: :controller, login: :sub_admin do
  let(:person) { create(:person) }
  let(:team) { create(:team) }
  let(:competition) { create(:competition) }

  it_behaves_like 'a backend resource controller' do
    let(:resource_attributes) do
      {
        name: 'FF Rostock',
        shortcut: 'Rostock',
        status: 'fire_station',
        latitude: '44.55',
        longitude: '66.77',
        image: fixture_file_upload('testfile.png', 'image/png'),
        state: 'MV',
      }
    end
  end
end
