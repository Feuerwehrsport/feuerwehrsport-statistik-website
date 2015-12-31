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
end