# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Backend::TeamSpellings', login: :sub_admin do
  let(:team) { create(:team) }

  it_behaves_like 'a backend resource controller' do
    let(:resource_attributes) do
      {
        name: 'FF Warino',
        shortcut: 'Warino',
        team_id: team.id,
      }
    end
  end
end
