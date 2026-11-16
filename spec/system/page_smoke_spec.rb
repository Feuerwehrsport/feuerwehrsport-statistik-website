# frozen_string_literal: true

require 'rails_helper'

# Opens the most important pages in headless Chrome. Cuprite raises JavaScript errors (js_errors: true), so this
# catches broken frontend code, e.g. after updating jQuery, Bootstrap or other assets.
# /records is left out: it loads fixed team IDs from the production database.
describe 'page smoke test' do
  before { page.driver.browser.url_blacklist = [/openstreetmap/] }

  let!(:score) { create(:score) }
  let!(:participation) { create(:person_participation) }
  let(:competition) { score.competition }
  let(:year) { competition.date.year }
  let(:frontend_paths) do
    [
      '/', '/people', "/people/#{score.person_id}", "/people/#{participation.person_id}",
      '/teams', "/teams/#{score.team_id}", "/teams/#{participation.group_score.team_id}",
      '/competitions', "/competitions/#{competition.id}",
      '/places', "/places/#{competition.place_id}", '/events', "/events/#{competition.event_id}",
      '/years', "/years/#{year}", "/years/#{year}/best_performance", "/years/#{year}/best_scores",
      '/best_of', '/last_competitions', '/feuerwehrsport', '/about', '/change_logs'
    ]
  end
  let(:backend_paths) do
    [
      '/backend', '/backend/admin_users', '/backend/change_requests', '/backend/import_requests', '/backend/imports',
      '/backend/people', "/backend/people/#{score.person_id}", "/backend/people/#{score.person_id}/edit",
      '/backend/teams', "/backend/teams/#{score.team_id}", "/backend/teams/#{score.team_id}/edit",
      '/backend/competitions', "/backend/competitions/#{competition.id}",
      "/backend/competitions/#{competition.id}/edit",
      '/backend/scores', "/backend/scores/#{score.id}/edit", '/backend/group_scores',
      '/backend/person_participations/new', '/backend/places', '/backend/places/new',
      '/backend/unchecked_teams', '/backend/repairs/team_score_move/new', '/backend/bla/badges/new'
    ]
  end

  def expect_pages_to_render(paths)
    paths.each do |path|
      visit path
      expect(page).to have_css('#footer'), "#{path} did not render completely"
    end
  end

  it 'renders frontend pages without JavaScript errors' do
    expect_pages_to_render(frontend_paths)
  end

  it 'renders backend pages without JavaScript errors' do
    user = create(:admin_user, :admin)
    visit '/session/new'
    fill_in 'E-Mail-Adresse', with: user.email_address
    fill_in 'Passwort', with: 'Secret123'
    find('input[type=submit], button[type=submit]', match: :first).click
    expect(page).to have_text 'Abmelden'

    expect_pages_to_render(backend_paths)
  end
end
