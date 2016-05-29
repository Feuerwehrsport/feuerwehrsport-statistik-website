require 'rails_helper'

describe "pages features", type: :feature do
  context "dashboard" do
    it "shows a lot of information" do
      visit root_path
      expect(page.find("h1")).to have_content 'Feuerwehrsport - die große Auswertung'
      expect(page.find("h4 a[href='/news/14']")).to have_content 'Löschangriff Position anzeigen'
      expect(page).to have_link 'MV-Cup - Ostseebad Nienhagen - 11.07.2014', href: competition_path(498)
      expect(page).to have_content 'Super Leistungen vom Jahr 2016'
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
      expect(first("td")).to have_link 'MV-Cup - Ostseebad Nienhagen - 11.07.2014', href: competition_path(498)
    end
  end

  context "wettkampf_manager" do
    it "shows other information" do
      visit wettkampf_manager_path
      expect(page).to have_content 'Hinweise zur Installation'
    end
  end

  context "records" do
    it "shows records" do
      person = Person.find(1)
      allow(Person).to receive(:find).and_return(person)
      competition = Competition.find(1)
      allow(Competition).to receive(:find).and_return(competition)

      visit records_path
      expect(page).to have_content 'Weltrekorde - Männer'
      expect(page).to have_content 'Deutsche Rekorde - Männer'
      expect(page).to have_content 'Deutsche Rekorde - Frauen'
    end
  end

  context "best_of" do
    it "shows best_of" do
      visit best_of_path
      expect(page).to have_content 'Die 100 schnellsten Zeiten'
      expect(page).to have_content 'Annekathrin Daßler'
      expect(page).to have_content '18.08.2012 - Taura, Pokallauf'
    end
  end
end