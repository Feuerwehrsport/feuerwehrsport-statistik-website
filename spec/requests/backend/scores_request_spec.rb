# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Backend::Scores', login: :sub_admin do
  let(:person) { create(:person) }
  let(:team) { create(:team) }
  let(:competition) { create(:competition) }
  let(:single_discipline_id) { create(:single_discipline, :hb_male).id }

  it_behaves_like 'a backend resource controller' do
    let(:resource_attributes) do
      {
        person_id: person.id,
        team_id: team.id,
        team_number: 2,
        time: 4455,
        single_discipline_id:,
        competition_id: competition.id,
      }
    end
  end
end
