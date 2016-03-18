require 'rails_helper'

describe "places features", type: :feature, js: true do
  context "index" do
    it "shows an overview" do
      visit places_path
      expect(page).to have_content '1 bis 10 von 99 Einträgen'
      click_on("Nächste")
      expect(page).to have_content '11 bis 20 von 99 Einträgen'
    end
  end

  context "show" do
    it "shows an competitions overview" do
      api_sign_in

      visit place_path(id: 1)
      expect(page).to have_content '1 bis 10 von 12 Einträgen'
      click_on("Nächste")
      expect(page).to have_content '11 bis 12 von 12 Einträgen'
    end

    it "can add geo position" do
      api_sign_in

      visit place_path(id: 1)
      within('.place-map-actions') do
        find('#change-geo-position').click
        find('.btn.btn-primary').click
      end
      expect(page).to_not have_content("Bitte warten")
      expect(page).to_not have_content("Geoposition hinzufügen")
      
      place = Place.find(1)
      expect(place.latitude).to eq 51
      expect(place.longitude).to eq 13
    end
  end
end