# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Errors' do
  describe 'GET #not_found' do
    it 'returns http success' do
      get '/404'
      expect(response).to have_http_status(:not_found)
      expect(response.body).to include('404 - Seite nicht gefunden')
    end
  end

  describe 'GET #unacceptable' do
    it 'returns http success' do
      get '/422'
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe 'GET #internal_server_error' do
    it 'returns http success' do
      get '/500'
      expect(response).to have_http_status(:internal_server_error)
    end
  end

  # behave like production: exceptions are handled by the exceptions app (config.exceptions_app = routes)
  def get_not_found_for(original_path)
    env_config = Rails.application.env_config
    old_values = env_config.slice('action_dispatch.show_exceptions', 'action_dispatch.show_detailed_exceptions')
    env_config['action_dispatch.show_exceptions'] = :all
    env_config['action_dispatch.show_detailed_exceptions'] = false
    get original_path
  ensure
    env_config.merge!(old_values)
  end

  describe 'unknown path' do
    it 'renders not found page via exceptions app' do
      get_not_found_for('/this/path/does/not/exist')
      expect(response).to have_http_status(:not_found)
      expect(response.body).to include('404 - Seite nicht gefunden')
    end
  end

  describe 'old path redirects' do
    {
      '/page/administration.html' => 'http://test.host/backend',
      '/page/best-of.html' => 'http://test.host/best_of',
      '/page/competition-12.html' => 'http://test.host/competitions/12',
      '/page/competitions.html' => 'http://test.host/competitions',
      '/page/date-12.html' => 'https://feusport.de',
      '/page/event-3.html' => 'http://test.host/events/3',
      '/page/feeds.html' => 'http://test.host/rss',
      '/page/home.html' => 'http://test.host/',
      '/page/logs.html' => 'http://test.host/change_logs',
      '/page/person-77.html' => 'http://test.host/people/77',
      '/page/place-5.html' => 'http://test.host/places/5',
      '/page/team-42.html' => 'http://test.host/teams/42',
      '/page/wettkampf-manager.html' => 'https://feusport.de/info',
      '/page/year-2014.html' => 'http://test.host/years/2014',
      '/page/years.html' => 'http://test.host/years',
      '/appointments/foo' => 'https://feusport.de',
      '/wettkampf_manager' => 'https://feusport.de/info',
      '/online_anmeldungen' => 'https://feusport.de/info',
      # NOTE: best-performance/best-scores are mapped crosswise in ErrorsController::OLD_PATHS
      '/page/best-performance-of-year-2015.html' => 'http://test.host/years/2015/best_scores',
      '/page/best-scores-of-year-2015.html' => 'http://test.host/years/2015/best_performance',
    }.each do |old_path, new_path|
      it "redirects #{old_path} permanently to #{new_path}" do
        get_not_found_for(old_path)
        expect(response).to have_http_status(:moved_permanently)
        expect(response.location).to eq new_path
      end
    end

    it 'does not redirect unknown old pages' do
      get_not_found_for('/page/unknown.html')
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'entity merge redirects' do
    let(:target) { create(:person) }
    let(:source) { create(:person, first_name: 'Alfredo') }

    before { EntityMerge.create!(source:, target:) }

    it 'redirects merged people to target' do
      source.delete
      get_not_found_for("/people/#{source.id}")
      expect(response).to have_http_status(:moved_permanently)
      expect(response.location).to eq "http://test.host/people/#{target.id}"
    end

    it 'redirects merged teams to target' do
      team_target = create(:team)
      team_source = create(:team, :mv)
      EntityMerge.create!(source: team_source, target: team_target)
      team_source.delete
      get_not_found_for("/teams/#{team_source.id}")
      expect(response).to have_http_status(:moved_permanently)
      expect(response.location).to eq "http://test.host/teams/#{team_target.id}"
    end

    it 'shows 404 for unknown people without merge' do
      get_not_found_for('/people/999999')
      expect(response).to have_http_status(:not_found)
    end
  end
end
