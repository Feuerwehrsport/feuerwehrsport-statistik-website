# frozen_string_literal: true

require 'rails_helper'

describe 'teams features' do
  let(:team) { create(:team) }
  let(:team_without_geo_location) { create(:team, :without_geo_location) }

  before { page.driver.browser.url_blacklist = [/openstreetmap/] }

  context 'when index' do
    it 'can add team' do
      api_sign_in

      # add one
      visit teams_path
      expect(page).to have_content('Verteilung der Bundesländer')
      find_by_id('add-team').click
      expect(page).to have_content('maximal 10 Zeichen')
      within('.fss-window') do
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

  context 'when show' do
    it 'can add logo' do
      api_sign_in

      visit team_path(team)
      find('.upload-logo').click

      within('.fss-window') do
        attach_file('logo_files', File.expand_path(file_fixture('testfile.pdf')))
        click_on('OK')
      end
      expect(page).to have_content('Der Fehlerbericht wurde gespeichert')

      change_request = ChangeRequest.last
      expect(change_request.content).to eq(key: 'team-logo', data: { team_id: team.id.to_s })
      expect(change_request.files_data.keys).to eq([:files])
      expect(change_request.files_data[:files][0]).to include(
        { filename: 'testfile.pdf', content_type: 'application/pdf' },
      )
      expect(change_request.files_data[:files][0][:binary]).to starting_with('JVBERi0xL')
    end

    it 'can add geo position' do
      api_sign_in

      visit team_path(team_without_geo_location)
      within('.team-map-actions') do
        find_by_id('add-geo-position').click
        find('.btn.btn-primary').click
      end
      expect(page).to have_no_content('Bitte warten')
      expect(page).to have_no_content('Geoposition hinzufügen')

      team = Team.find(team_without_geo_location.id)
      expect(team.latitude).to eq 51
      expect(team.longitude).to eq 13
    end

    it 'can add change request with team-merge' do
      team
      team_without_geo_location

      api_sign_in

      visit team_path(team)
      find_by_id('add-change-request').click

      within('.fss-window') do
        choose('Team ist doppelt vorhanden')
        click_on('OK')

        select('FF Warin', from: 'Richtiges Team:')
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
      find_by_id('add-change-request').click

      within('.fss-window') do
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
