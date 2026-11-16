# frozen_string_literal: true

require 'rails_helper'

describe 'places features' do
  let(:place) { create(:place) }

  before { page.driver.browser.url_blacklist = [/openstreetmap/] }

  context 'when index' do
    it 'shows an overview' do
      create_list(:place, 13).each { |place| create(:competition, place:) }

      visit places_path
      expect(page).to have_text '1 bis 10 von 13 Einträgen'
      click_on('Nächste')
      expect(page).to have_text '11 bis 13 von 13 Einträgen'
      click_on 'Zurück'
      expect(page).to have_text '1 bis 10 von 13 Einträgen'
    end
  end

  context 'when show' do
    it 'shows an competitions overview' do
      create_list(:competition, 13, place:)

      visit place_path(place)
      expect(page).to have_text '1 bis 10 von 13 Einträgen'
      click_on('Nächste')
      expect(page).to have_text '11 bis 13 von 13 Einträgen'
      click_on 'Zurück'
      expect(page).to have_text '1 bis 10 von 13 Einträgen'
    end

    it 'can add geo position' do
      api_sign_in

      visit place_path(place)
      within('.place-map-actions') do
        click_on 'Geoposition hinzufügen'
        expect(page).to have_text('Verschiebe den roten Marker')
        click_on 'Speichern'
      end
      within('dialog.contribution-dialog') do
        expect(page).to have_text('Breite 51.0, Länge 13.0')
        click_on 'Position speichern'
      end
      expect(page).to have_no_css('dialog[open]')
      expect(page).to have_button('Geoposition bearbeiten')

      expect(place.reload).to have_attributes(latitude: 51, longitude: 13)
      expect(ChangeLog.last).to have_attributes(action: 'update-place:geo-position')
    end
  end
end
