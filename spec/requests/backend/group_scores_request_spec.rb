# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Backend::GroupScores', login: :sub_admin do
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

  describe 'competition filter' do
    let!(:competitions) { create_list(:competition, 20) }

    it 'loads the selected competition once, not once per option of the select' do
      competition_queries = 0
      pattern = /FROM "competitions" WHERE "competitions"."id"/
      count = ->(*, payload) { competition_queries += 1 if payload[:sql].match?(pattern) }
      ActiveSupport::Notifications.subscribed(count, 'sql.active_record') do
        get "/backend/group_scores?q[competition_scope]=#{competitions.first.id}"
      end
      expect(response).to be_successful
      expect(response.body).to include(%(<option selected value="#{competitions.first.id}">))
      # a few lookups of the selected competition (filtering, filter?, view), but not one per option (20)
      expect(competition_queries).to be <= 4
    end
  end
end
