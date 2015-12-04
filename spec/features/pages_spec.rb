require 'rails_helper'

describe "pages features", type: :feature do
  context "dashboard" do
    it "shows a lot of information" do
      visit root_path
      expect(page.find("h1")).to have_content 'Feuerwehrsport - die große Auswertung'
      expect(page.find("h4 a[href='/news/27']")).to have_content 'Neue Seite im Aufbau'
      expect(page).to have_content 'Super Leistungen vom Jahr 2015'
      expect(page).to have_content 'Fehler in den Daten'
    end
  end
end