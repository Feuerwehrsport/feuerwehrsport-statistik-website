require 'rails_helper'

describe 'teams features' do
  let(:team) { create(:team) }
  let(:team_without_geo_location) { create(:team, :without_geo_location) }

  before { page.driver.browser.url_blacklist = ['openstreetmap'] }

  context 'index' do
    it 'can step pages' do
      create_list(:team, 13)

      visit teams_path
      expect(page).to have_content '1 bis 10 von 13 Einträgen'
      save_review_screenshot
      click_on 'Nächste'
      expect(page).to have_content '11 bis 13 von 13 Einträgen'
      click_on 'Zurück'
      expect(page).to have_content '1 bis 10 von 13 Einträgen'
    end

    it 'can add team' do
      api_sign_in

      # add one
      visit teams_path
      expect(page).to have_content('Verteilung der Bundesländer')
      find('#add-team').click
      expect(page).to have_content('maximal 10 Zeichen')
      within('.fss-window') do
        save_review_screenshot
        expect(page).to have_content('Mannschaft anlegen')
        fill_in 'Name', with: '00Mannschaft_xyz'
        fill_in 'Abkürzung', with: 'Abk789'
        select('Einzelne Feuerwehr', from: 'Typ der Mannschaft')
        click_on('OK')
      end
      expect(page).to have_content('00Mannschaft_xyz')
      expect(page).to have_content('Abk789')

      team = Team.where(name: '00Mannschaft_xyz')
      expect(team.count).to eq 1
      expect(team.first.attributes.symbolize_keys).to include(
        name: '00Mannschaft_xyz',
        shortcut: 'Abk789',
        status: 'fire_station',
      )
    end
  end

  context 'show' do
    it 'can add logo' do
      api_sign_in

      visit team_path(team)
      find('.upload-logo').click

      within('.fss-window') do
        save_review_screenshot
        attach_file('logo_files', Rails.root.join('spec/fixtures/testfile.pdf'))
        click_on('OK')
      end
      expect(page).to have_content('Der Fehlerbericht wurde gespeichert')

      change_request = ChangeRequest.last
      expect(change_request.content).to eq(key: 'team-logo', data: { team_id: '1' })
      expect(change_request.files_data).to eq(
        files: [{ binary: '', filename: 'testfile.pdf', content_type: 'application/pdf' }],
      )
    end

    it 'can add geo position' do
      api_sign_in

      visit team_path(team_without_geo_location)
      within('.team-map-actions') do
        save_review_screenshot
        find('#add-geo-position').click
        find('.btn.btn-primary').click
      end
      expect(page).not_to have_content('Bitte warten')
      expect(page).not_to have_content('Geoposition hinzufügen')

      team = Team.find(team_without_geo_location.id)
      expect(team.latitude).to eq 51
      expect(team.longitude).to eq 13
    end

    it 'can add change request with team-merge' do
      team
      team_without_geo_location

      api_sign_in

      visit team_path(team)
      find('#add-change-request').click

      within('.fss-window') do
        save_review_screenshot
        choose('Team ist doppelt vorhanden')
        click_on('OK')

        expect(page).to have_content('Mannschaft zusammenführen')
        click_on('OK')
      end
      expect(page).to have_content('Der Fehlerbericht wurde gespeichert')

      change_request_content = ChangeRequest.last.content
      expect(change_request_content).to include key: 'team-merge'
      expect(change_request_content[:data]).to eq(
        team_id: team.id.to_s,
        correct_team_id: team_without_geo_location.id.to_s,
      )
    end

    it 'can add change request with team-correction' do
      api_sign_in
      visit team_path(team)
      find('#add-change-request').click

      within('.fss-window') do
        save_review_screenshot
        choose('Team ist falsch geschrieben')
        click_on('OK')

        expect(page).to have_content('Mannschaft korrigieren')
        click_on('OK')
      end
      expect(page).to have_content('Der Fehlerbericht wurde gespeichert')

      change_request_content = ChangeRequest.last.content
      expect(change_request_content).to include key: 'team-correction'
      expect(change_request_content[:data]).to eq(
        team_id: team.id.to_s,
        team: { name: 'FF Warin', shortcut: 'Warin', status: 'fire_station' },
      )
    end
  end
end
