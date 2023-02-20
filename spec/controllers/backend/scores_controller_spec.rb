# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Backend::ScoresController, type: :controller, login: :sub_admin do
  let(:person) { create(:person) }
  let(:team) { create(:team) }
  let(:competition) { create(:competition) }

  it_behaves_like 'a backend resource controller' do
    let(:resource_attributes) do
      {
        person_id: person.id,
        team_id: team.id,
        team_number: 2,
        time: 4455,
        discipline: 'hb',
        competition_id: competition.id,
      }
    end
  end
end
