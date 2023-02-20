# frozen_string_literal: true
require 'rails_helper'

RSpec.describe API::TeamSpellingsController, type: :controller do
  describe 'GET index' do
    let!(:ts) { create(:team_spelling) }

    it 'returns team_spellings' do
      get :index
      expect_json_response
      expect(json_body[:team_spellings].first).to eq(team_id: ts.team_id, name: 'FF Warino', shortcut: 'Warino')
      expect(json_body[:team_spellings].count).to eq 1
    end
  end
end
