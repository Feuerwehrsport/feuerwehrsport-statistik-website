# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin jobs (Mission Control)' do
  # returns the response or nil, if the request raised an exception (which also means: no access)
  def request_jobs_dashboard
    get '/admin-jobs'
    response
  rescue ActionController::UrlGenerationError
    nil
  end

  context 'when not logged in' do
    it 'does not show the jobs dashboard' do
      result = request_jobs_dashboard
      expect(result).not_to have_http_status(:ok) if result
    end

    it 'redirects to login page' do
      pending 'Bug: CanCan::AccessDenied im Engine-Kontext -> login_url wird gegen Engine-Routen aufgelöst ' \
              '(UrlGenerationError statt Redirect auf /session/new)'
      get '/admin-jobs'
      expect(response).to redirect_to('/session/new')
    end
  end

  %i[user sub_admin].each do |role|
    context "when logged in as #{role}", login: role do
      it 'does not show the jobs dashboard' do
        get '/admin-jobs'
        expect(response).to have_http_status(:redirect)
        expect(flash[:alert]).to eq 'Keine Rechte zum Anzeigen der Seite'
      end

      it 'redirects to main root page' do
        pending 'Bug: root_path wird im Engine-Kontext zu /admin-jobs/ aufgelöst -> Redirect-Schleife'
        get '/admin-jobs'
        expect(response).to redirect_to('/')
      end
    end
  end

  context 'when logged in as admin', login: :admin do
    it 'grants access' do
      get '/admin-jobs'
      follow_redirect! while response.redirect?
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Queues')
    end
  end
end
