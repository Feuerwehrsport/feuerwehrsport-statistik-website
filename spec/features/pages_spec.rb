require 'rails_helper'

describe "pages features", type: :feature do
  context "dashboard" do
    it "shows a lot of information" do
      visit root_path
      expect(page.find("h1")).to have_content 'Feuerwehrsport - die große Auswertung'
      expect(page.find("h4 a[href='/news/27']")).to have_content 'Neue Seite im Aufbau'
      expect(page).to have_link 'Pokallauf - Tüttleben - 19.09.2015 (1. Nachtsteigen)', href: competition_path(920)
      expect(page).to have_content 'Super Leistungen vom Jahr 2015'
      expect(page).to have_content 'Fehler in den Daten'
    end
  end

  context "legal_notice" do
    it "shows a contact information" do
      visit impressum_path
      expect(page).to have_content 'statistik@feuerwehrsport-teammv.de'
    end
  end

  context "firesport_overview" do
    it "shows videos and other information" do
      visit feuerwehrsport_path
      expect(page).to have_content 'Feuerwehrsport - verschiedene Angebote'
      expect(page).to have_link 'Weitere Informationen', href: wettkampf_manager_path
    end
  end

  context "last_competitions_overview" do
    it "shows list of the last inserted competitions" do
      visit last_competitions_path
      expect(page).to have_content 'Neu eingetragene Wettkämpfe'
      expect(first("td")).to have_link 'Pokallauf - Tüttleben - 19.09.2015 (1. Nachtsteigen)', href: competition_path(920)
    end
  end
end