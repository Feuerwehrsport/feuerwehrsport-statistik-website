require 'rails_helper'

RSpec.describe Backend::GroupScoreCategoriesController, type: :controller, login: :sub_admin do
  let(:competition) { create(:competition) }
  let(:group_score_type) { create(:group_score_type) }

  it_behaves_like 'a backend resource controller' do
    let(:resource_attributes) do
      {
        name: 'default',
        competition_id: competition.id,
        group_score_type_id: group_score_type.id,
      }
    end
  end
end
