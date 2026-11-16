# frozen_string_literal: true

require 'rails_helper'

describe 'teams features' do
  let(:team) { create(:team) }
  let(:team_without_geo_location) { create(:team, :without_geo_location) }

  before { page.driver.browser.url_blacklist = [/openstreetmap/] }

  def within_dialog(&)
    within('dialog.contribution-dialog', &)
  end

  def expect_change_request_saved
    expect(page).to have_text('Der Fehlerbericht wurde gespeichert')
    within_dialog { click_on 'Schließen' }
    expect(page).to have_no_css('dialog[open]')
  end

  context 'when index' do
    it 'can add team' do
      api_sign_in

      visit teams_path
      expect(page).to have_text('Verteilung der Bundesländer')
      click_on 'Anlegen'
      within_dialog do
        expect(page).to have_text('Mannschaft anlegen')
        expect(page).to have_text('maximal 10 Zeichen')
        fill_in 'Name', with: '00Mannschaft_xyz'
        fill_in 'Abkürzung', with: 'Abk789'
        select('Einzelne Feuerwehr', from: 'Typ der Mannschaft')
        click_on('Anlegen')
      end
      expect(page).to have_no_css('dialog[open]')

      team = Team.where(name: '00Mannschaft_xyz')
      expect(team.count).to eq 1
      expect(team.first.attributes.symbolize_keys).to include(
        name: '00Mannschaft_xyz',
        shortcut: 'Abk789',
        status: 'fire_station',
      )
      expect(ChangeLog.last).to have_attributes(action: 'create-team')
    end
  end

  context 'when show' do
    it 'can add logo' do
      api_sign_in

      visit team_path(team)
      find('.upload-logo').click

      within_dialog do
        expect(page).to have_text('Neues Logo')
        attach_file('Neues Logo', File.expand_path(file_fixture('testfile.pdf')))
        click_on('Logo hochladen')
      end
      expect_change_request_saved

      change_request = ChangeRequest.last
      expect(change_request.content).to eq(key: 'team-logo', data: { team_id: team.id.to_s })
      expect(change_request.files_data.keys).to eq([:files])
      expect(change_request.files_data[:files][0]).to include(
        { filename: 'testfile.pdf', content_type: 'application/pdf' },
      )
      expect(change_request.files_data[:files][0][:binary]).to starting_with('JVBERi0xL')
    end

    it 'can add and report a link' do
      api_sign_in

      visit team_path(team)
      click_on 'Link hinzufügen'
      within_dialog do
        fill_in 'Name', with: 'Webseite'
        fill_in 'Link', with: 'www.ff-warin.de'
        click_on 'Hinzufügen'
      end
      expect(page).to have_no_css('dialog[open]')
      expect(page).to have_link('Webseite', href: 'https://www.ff-warin.de')
      expect(Link.last).to have_attributes(linkable: team, label: 'Webseite')

      find('.report-link').click
      within_dialog do
        expect(page).to have_text('Soll der Link Webseite')
        click_on 'Melden'
      end
      expect_change_request_saved
      expect(ChangeRequest.last.content).to eq(key: 'report-link', data: { link_id: Link.last.id.to_s })
    end

    it 'can edit the state' do
      api_sign_in

      visit team_path(team)
      find_by_id('edit-state').click
      within_dialog do
        select('Brandenburg', from: 'Land')
        click_on('Speichern')
      end
      expect(page).to have_no_css('dialog[open]')
      expect(team.reload.state).to eq 'BB'
      expect(ChangeLog.last).to have_attributes(action: 'update-team:state')
    end

    it 'can add geo position' do
      api_sign_in

      visit team_path(team_without_geo_location)
      within('.team-map-actions') do
        click_on 'Geoposition hinzufügen'
        click_on 'Speichern'
      end
      within_dialog { click_on 'Position speichern' }
      expect(page).to have_no_css('dialog[open]')
      expect(page).to have_no_text('Geoposition hinzufügen')
      expect(ChangeLog.last).to have_attributes(action: 'update-team:geo-position')

      team = Team.find(team_without_geo_location.id)
      expect(team.latitude).to eq 51
      expect(team.longitude).to eq 13
    end

    it 'can start map editing from the change request dialog' do
      api_sign_in

      visit team_path(team)
      click_on 'Fehler mit diesem Team melden'
      within_dialog { click_on 'Kartenposition ändern' }
      expect(page).to have_no_css('dialog[open]')
      within('.team-map-actions') { expect(page).to have_css('.btn.btn-primary', text: 'Speichern') }
    end

    it 'can add change request with team-merge' do
      team
      team_without_geo_location

      api_sign_in

      visit team_path(team)
      click_on 'Fehler mit diesem Team melden'

      within_dialog do
        click_on 'Mannschaft ist doppelt vorhanden'
        fill_in 'Mannschaft suchen', with: 'Warin'
        click_on 'Suchen'
        choose('FF Warin (Warin)')
        click_on('Fehler melden')
      end
      expect_change_request_saved

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
      click_on 'Fehler mit diesem Team melden'

      within_dialog do
        click_on 'Mannschaft ist falsch geschrieben'
        expect(page).to have_field('Name', with: 'FF Warin')
        click_on('Fehler melden')
      end
      expect_change_request_saved

      change_request_content = ChangeRequest.last.content
      expect(change_request_content).to include key: 'team-correction'
      expect(change_request_content[:data]).to eq(
        team_id: team.id.to_s,
        team: { name: 'FF Warin', shortcut: 'Warin', status: 'fire_station' },
      )
    end
  end
end
