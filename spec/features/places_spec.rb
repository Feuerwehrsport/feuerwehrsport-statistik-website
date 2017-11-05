require 'rails_helper'

describe 'places features', type: :feature, js: true do
  let(:place) { create(:place) }

  before { page.driver.browser.url_blacklist = ['openstreetmap'] }

  context 'index' do
    it 'shows an overview' do
      13.times { create(:competition, place: create(:place)) }

      visit places_path
      expect(page).to have_content '1 bis 10 von 13 Einträgen'
      save_review_screenshot
      click_on('Nächste')
      expect(page).to have_content '11 bis 13 von 13 Einträgen'
      click_on 'Zurück'
      expect(page).to have_content '1 bis 10 von 13 Einträgen'
    end
  end

  context 'show' do
    it 'shows an competitions overview' do
      create_list(:competition, 13, place: place)

      visit place_path(place)
      expect(page).to have_content '1 bis 10 von 13 Einträgen'
      save_review_screenshot
      click_on('Nächste')
      expect(page).to have_content '11 bis 13 von 13 Einträgen'
      click_on 'Zurück'
      expect(page).to have_content '1 bis 10 von 13 Einträgen'
    end

    it 'can add geo position' do
      api_sign_in

      visit place_path(place)
      within('.place-map-actions') do
        save_review_screenshot
        find('#change-geo-position').click
        find('.btn.btn-primary').click
      end
      expect(page).not_to have_content('Bitte warten')
      expect(page).not_to have_content('Geoposition hinzufügen')

      place = Place.last
      expect(place.latitude).to eq 51
      expect(place.longitude).to eq 13
    end
  end
end
