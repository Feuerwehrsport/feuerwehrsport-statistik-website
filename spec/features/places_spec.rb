# frozen_string_literal: true

require 'rails_helper'

describe 'places features', :js do
  let(:place) { create(:place) }

  before { page.driver.browser.url_blacklist = [/openstreetmap/] }

  context 'when index' do
    it 'shows an overview' do
      create_list(:place, 13).each { |place| create(:competition, place:) }

      visit places_path
      expect(page).to have_content '1 bis 10 von 13 Einträgen'
      click_on('Nächste')
      expect(page).to have_content '11 bis 13 von 13 Einträgen'
      click_on 'Zurück'
      expect(page).to have_content '1 bis 10 von 13 Einträgen'
    end
  end

  context 'when show' do
    it 'shows an competitions overview' do
      create_list(:competition, 13, place:)

      visit place_path(place)
      expect(page).to have_content '1 bis 10 von 13 Einträgen'
      click_on('Nächste')
      expect(page).to have_content '11 bis 13 von 13 Einträgen'
      click_on 'Zurück'
      expect(page).to have_content '1 bis 10 von 13 Einträgen'
    end

    it 'can add geo position' do
      api_sign_in

      visit place_path(place)
      within('.place-map-actions') do
        find_by_id('change-geo-position').click
        find('.btn.btn-primary').click
      end
      expect(page).to have_no_content('Bitte warten')
      expect(page).to have_no_content('Geoposition hinzufügen')

      place = Place.last
      expect(place.latitude).to eq 51
      expect(place.longitude).to eq 13
    end
  end
end
