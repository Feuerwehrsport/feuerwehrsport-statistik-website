require 'rails_helper'

describe "competitions features", type: :feature, js: true, driver: :webkit do
  context "index" do
    it "shows an overview" do
      visit competitions_path
      expect(page).to have_content '1 bis 10 von 304 Einträgen'
      click_on("Nächste")
      expect(page).to have_content '11 bis 20 von 304 Einträgen'

      expect(page).to have_content 'Grit Thurow'
      expect(page).to_not have_content 'FF Gamstädt'
      find('a[href="#tav-tab-img-width-20-title-loschangriff-nass-src-assets-di-1"]').click
      expect(page).to have_content 'FF Gamstädt'
      expect(page).to_not have_content 'Grit Thurow'
    end
  end

  context "show" do
    it "shows the competition" do
      visit competition_path(id: 7)
      expect(page).to have_content("Hindernisbahn weiblich")
      expect(page).to have_content("1 bis 10 von 22 Einträgen")
      expect(page).to have_content("Hindernisbahn weiblich Mannschaftswertung")

      expect(page).to have_content("Hindernisbahn männlich")
      expect(page).to have_content("1 bis 10 von 36 Einträgen")
      expect(page).to have_content("Hindernisbahn männlich Mannschaftswertung")

      expect(page).to_not have_content("Hakenleitersteigen weiblich")
      expect(page).to_not have_content("Hakenleitersteigen weiblich Mannschaftswertung")

      expect(page).to have_content("Hakenleitersteigen männlich")
      expect(page).to have_content("1 bis 10 von 35 Einträgen")
      expect(page).to have_content("Hakenleitersteigen männlich Mannschaftswertung")

      expect(page).to_not have_content("Zweikampf weiblich")
      expect(page).to have_content("Zweikampf männlich")

      expect(page).to have_content("Löschangriff nass weiblich")
      expect(page).to have_content("Löschangriff nass männlich")
      expect(page).to have_content("Standardwertung WKO DIN-Pumpe")

      expect(page).to have_link("Bericht beim Team-MV")

      within('.missed-1') do
        expect(page).to have_content("Folgende Informationen fehlen:")
      end
    end

    it "adds change requests" do
      api_sign_in
      
      visit competition_path(id: 300)
      find('#add-change-request').click

      within('.fss-window') do
        expect(page).to have_content("Auswahl des Fehlers")
        choose('Name des Wettkampfs vorschlagen')
        click_on("OK")
      end

      within('.fss-window') do
        expect(page).to have_content("Namen vorschlagen")
        fill_in "Name", with: "Superduperwettkampf"
        click_on("OK")
      end
      expect(page).to have_content("Der Fehlerbericht wurde gespeichert")
      click_on("OK")

      change_request_content = ChangeRequest.last.content
      expect(change_request_content).to include key: "competition-change-name"
      expect(change_request_content[:data]).to eq(competition_id: "300", name: "Superduperwettkampf")


      find('#add-change-request').click

      within('.fss-window') do
        expect(page).to have_content("Auswahl des Fehlers")
        choose('Hinweis geben')
        click_on("OK")
      end

      within('.fss-window') do
        expect(page).to have_content("Hinweis beschreiben")
        fill_in "Beschreibung", with: "Wetterbericht"
        click_on("OK")
      end
      expect(page).to have_content("Der Fehlerbericht wurde gespeichert")
      click_on("OK")

      change_request_content = ChangeRequest.last.content
      expect(change_request_content).to include key: "competition-add-hint"
      expect(change_request_content[:data]).to eq(competition_id: "300", hint: "Wetterbericht")
    end
  end

  context "file upload" do
    it "adds change requests" do
      api_sign_in
      
      visit competition_path(id: 300)
      find('#add-file').click
      expect(page).to have_content("Es dürfen nur PDFs hochgeladen werden.")
      attach_file('competition_file[0][file]', "#{Rails.root}/spec/fixtures/testfile.pdf")
      check("competition_file[0][fs_female]")
      click_on("Hochladen")
      expect(page).to have_content("testfile.pdf")
    end
  end
end