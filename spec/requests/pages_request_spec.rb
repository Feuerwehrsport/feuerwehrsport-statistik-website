# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Pages' do
  let!(:score) { create(:score, :double) }

  describe 'GET dashboard' do
    it 'assigns a lot information' do
      get '/'
      expect(controller.instance_variable_get(:@last_competitions).count).to eq 1
      expect(response).to be_successful
    end
  end

  describe 'GET about' do
    it 'assigns information' do
      get '/about'
      expect(response).to be_successful
    end
  end

  describe 'GET last_competitions' do
    it 'assigns the 100 last competitions' do
      get '/last_competitions'
      expect(controller.instance_variable_get(:@last_competitions).count).to eq 1
      expect(controller.instance_variable_get(:@last_competitions).first.id).to eq score.competition_id
    end
  end

  describe 'GET firesport_overview' do
    it 'assigns nothing' do
      get '/feuerwehrsport'
      expect(response).to be_successful
    end
  end

  describe 'GET records' do
    it 'renders the records of config/records.yml (unknown people and teams are skipped)' do
      get '/records'
      expect(response).to be_successful
      expect(response.body).to include('Deutsche Rekorde – Männer', '13,34 s', 'Nikita Ukolov', 'Stand: 29.01.2026')
    end
  end

  {
    '/impressum' => 'Impressum',
    '/datenschutz' => 'Datenschutzerklärung',
    '/best_of' => 'Die 100 schnellsten Zeiten',
    '/feuerwehrsport' => 'Feuerwehrsport kennenlernen',
    '/about' => 'Statistiken über diese Seite',
  }.each do |path, title|
    describe "GET #{path}" do
      it 'renders page with title' do
        get path
        expect(response).to be_successful
        expect(response.body).to include("<title>#{title}")
      end
    end
  end

  describe 'GET dashboard with title' do
    it 'renders dashboard' do
      get '/'
      expect(response.body).to include('<title>Feuerwehrsport – die große Auswertung', 'Deutsche Rekorde', '16,44 s')
    end
  end

  describe 'domain redirect' do
    it 'redirects requests for another host permanently to same path on default host' do
      host! 'www.other-domain.de'
      get '/about'
      expect(response).to have_http_status(:moved_permanently)
      expect(response.location).to eq 'http://test.host/about'
    end
  end
end
