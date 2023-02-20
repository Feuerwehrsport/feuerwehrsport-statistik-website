# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Backend::GroupScoresController, login: :sub_admin do
  let(:team) { create(:team) }
  let(:group_score_category) { create(:group_score_category) }

  it_behaves_like 'a backend resource controller' do
    let(:resource_attributes) do
      {
        team_id: team.id,
        team_number: 2,
        gender: 'male',
        time: 4455,
        group_score_category_id: group_score_category.id,
        run: 'A',
      }
    end
  end
end
