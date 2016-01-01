require 'rails_helper'

describe "competitions features", type: :feature, js: true, driver: :webkit do
  context "index" do
    it "shows an overview" do
      visit places_path
      expect(page).to have_content '1 bis 10 von 311 Einträgen'
      click_on("Nächste")
      expect(page).to have_content '11 bis 20 von 311 Einträgen'
    end
  end

  context "show" do
    it "can add geo position" do
      api_sign_in

      visit place_path(id: 219)
      within('.place-map-actions') do
        find('#change-geo-position').click
        find('.btn.btn-primary').click
      end
      expect(page).to_not have_content("Bitte warten")
      expect(page).to_not have_content("Geoposition hinzufügen")
      
      place = Place.find(219)
      expect(place.latitude).to eq 51
      expect(place.longitude).to eq 13
    end
  end
end