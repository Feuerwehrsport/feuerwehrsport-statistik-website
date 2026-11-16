# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Backend::Teams', login: :sub_admin do
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
        state: 'MV',
      }
    end
  end

  describe 'GET show' do
    it 'links has_many associations with a backend controller, but not SQL views' do
      get "/backend/teams/#{team.id}"
      expect(response).to be_successful
      tables = response.parsed_body.css('[data-remote-index-table]')
      paths = tables.map { |table| URI.parse(table['data-remote-index-table']).path }
      expect(paths).to include('/backend/scores', '/backend/group_scores', '/backend/links', '/backend/team_spellings')
      expect(paths).not_to include('/backend/team_members', '/backend/team_competitions')
    end
  end
end
