# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::TeamMembers' do
  describe 'GET index' do
    let!(:score) { create(:score) }

    it 'returns team_members' do
      get '/api/team_members'
      expect_json_response
      expect(json_body[:team_members].first).to eq(person_id: score.person_id, team_id: score.team_id)
      expect(json_body[:team_members].count).to eq 1
    end
  end
end
