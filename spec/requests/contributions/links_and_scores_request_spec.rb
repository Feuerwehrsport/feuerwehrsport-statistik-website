# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Contributions::Links and ScoreTeams', login: :api do
  describe 'links' do
    let!(:team) { create(:team) }

    def create_link(url, linkable_type: 'Team')
      post '/contributions/links', params: { linkable_type:, linkable_id: team.id, link: { label: 'Seite', url: } }
    end

    it 'creates a link with change log' do
      expect { create_link('https://example.com/a') }.to change(Link, :count).by(1)
      expect(Link.last).to have_attributes(linkable: team, url: 'https://example.com/a')
      expect(ChangeLog.last).to have_attributes(action: 'create-link', api_user: login_user)
    end

    it 'normalizes urls' do
      expect(Contributions::LinksController.normalize_url(' www.example.com ')).to eq 'https://www.example.com'
      expect(Contributions::LinksController.normalize_url('http://https://example.com')).to eq 'https://example.com'
      expect(Contributions::LinksController.normalize_url('http://example.com')).to eq 'http://example.com'
    end

    it 'rejects invalid urls' do
      expect { create_link('javascript:alert(1)') }.not_to change(Link, :count)
      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'only allows teams and competitions' do
      expect { create_link('https://example.com', linkable_type: 'AdminUser') }.not_to change(Link, :count)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'score teams' do
    let!(:score) { create(:score, :hb, team: nil, team_number: 0) }
    let!(:second_score) { create(:score, :hl, person: score.person, competition: score.competition, team: nil) }
    let!(:team) { create(:team) }
    let(:path) { "/contributions/scores/#{score.id}/team" }

    it 'suggests teams of the person or search results' do
      get "#{path}/edit", params: { q: 'Warin' }
      expect(response.body).to include("#{team.name} (#{team.shortcut})", 'ohne Mannschaft')
    end

    it 'updates all scores of the person at the competition' do
      patch path, params: { team_id: team.id, team_numbers: { score.id => '1', second_score.id => '-5' } }
      expect(score.reload).to have_attributes(team_id: team.id, team_number: 1)
      expect(second_score.reload).to have_attributes(team_id: team.id, team_number: -5)
      expect(ChangeLog.where(action: 'update-score:team').count).to eq 2
    end

    it 'removes the team' do
      score.update!(team:)
      patch path, params: { team_id: 'none', team_numbers: { score.id => '0', second_score.id => '0' } }
      expect(score.reload.team_id).to be_nil
    end

    it 'rejects invalid team numbers' do
      patch path, params: { team_id: team.id, team_numbers: { score.id => '99', second_score.id => '1' } }
      expect(response).to have_http_status(:unprocessable_content)
      expect(score.reload.team_id).to be_nil
    end
  end
end
