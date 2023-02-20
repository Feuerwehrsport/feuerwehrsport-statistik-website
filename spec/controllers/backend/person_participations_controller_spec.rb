# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Backend::PersonParticipationsController, type: :controller, login: :sub_admin do
  let(:person) { create(:person) }
  let(:group_score) { create(:group_score) }

  it_behaves_like 'a backend resource controller' do
    let(:resource_attributes) do
      {
        person_id: person.id,
        group_score_id: group_score.id,
        position: 3,
      }
    end
  end
end
