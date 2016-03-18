require 'rails_helper'

describe "events features", type: :feature, js: true do
  context "index" do
    it "shows an overview" do
      visit events_path
      expect(page).to have_content '1 bis 10 von 20 Einträgen'
      click_on("Nächste")
      expect(page).to have_content '11 bis 20 von 20 Einträgen'
    end
  end

  context "show" do
    it "shows an competitions overview" do
      api_sign_in

      visit event_path(id: 15)
      expect(page).to have_content '1 bis 10 von 12 Einträgen'
      click_on("Nächste")
      expect(page).to have_content '11 bis 12 von 12 Einträgen'
    end
  end
end