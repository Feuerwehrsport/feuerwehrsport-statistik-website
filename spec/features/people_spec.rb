require 'rails_helper'

describe "people", type: :feature, js: true, driver: :webkit do
  it "can add person" do
    api_sign_in

    # add one
    visit people_path
    find("#add-person").click
    within('.fss-window') do
      expect(page).to have_content("Person hinzufügen")
      fill_in "Vorname", with: "Vorname"
      fill_in "Nachname", with: "00AABBCC"
      select('weiblich', from: 'Geschlecht')
      select('Österreich', from: 'Nation')
      click_on("OK")
    end

    Timeout.timeout(5) do
      loop do
        person = Person.where(last_name: "00AABBCC")
        break if person.present?
      end
    end
    person = Person.where(last_name: "00AABBCC")

    expect(person.count).to eq 1
    expect(person.first.attributes.symbolize_keys).to include(
      last_name: "00AABBCC",
      first_name: "Vorname",
      gender: 0,
      nation_id: 2,
    )
  end

  context "add change request" do
    it "can put people merge" do
      api_sign_in

      # add one
      visit person_path(id: 42)
      find("#add-change-request").click
      within('.fss-window') do
        expect(page).to have_content("Auswahl des Fehlers")
        choose("Person ist falsch geschrieben")
        click_on("OK")
        
        expect(page).to have_content("Korrektur des Fehlers")
        choose("Richtige Schreibweise auswählen (für Administrator VIEL einfacher)")
        click_on("OK")
        
        expect(page).to have_content("Namen korrigieren")
        select("Bittner, Toni (männlich)", from: "Richtige Person")
        click_on("OK")
      end
      expect(page).to have_content("Der Fehlerbericht wurde gespeichert")

      change_request_content = ChangeRequest.last.content
      expect(change_request_content).to eq(key: "person-merge", data: { person_id: "42", correct_person_id: "88" })
    end

    it "can correct person" do
      api_sign_in

      # add one
      visit person_path(id: 42)
      find("#add-change-request").click
      within('.fss-window') do
        expect(page).to have_content("Auswahl des Fehlers")
        choose("Person ist falsch geschrieben")
        click_on("OK")
        
        expect(page).to have_content("Korrektur des Fehlers")
        choose("Selbst korrekte Schreibweise hinzufügen")
        click_on("OK")
        

        expect(page).to have_content("Namen korrigieren")
        fill_in "Vorname", with: "Vorname"
        fill_in "Nachname", with: "00AABBCC"
        click_on("OK")
      end
      expect(page).to have_content("Der Fehlerbericht wurde gespeichert")

      change_request_content = ChangeRequest.last.content
      expect(change_request_content).to eq(key: "person-correction", data: { person_id: "42", person: { first_name: "Vorname", last_name: "00AABBCC" } })
    end

    it "can correct nation" do
      api_sign_in

      # add one
      visit person_path(id: 42)
      find("#add-change-request").click
      within('.fss-window') do
        expect(page).to have_content("Auswahl des Fehlers")
        choose("Person ist falscher Nation zugeordnet")
        click_on("OK")
        
        expect(page).to have_content("Andere Nation")
        select("Ungarn", from: "Nation")
        click_on("OK")
      end
      expect(page).to have_content("Der Fehlerbericht wurde gespeichert")

      change_request_content = ChangeRequest.last.content
      expect(change_request_content).to eq(key: "person-change-nation", data: { person_id: "42", nation_id: "3" })
    end

    it "can add description" do
      api_sign_in

      # add one
      visit person_path(id: 42)
      find("#add-change-request").click
      within('.fss-window') do
        expect(page).to have_content("Auswahl des Fehlers")
        choose("Etwas anderes")
        click_on("OK")
        
        expect(page).to have_content("Fehler beschreiben")
        fill_in("Beschreibung", with: "Beschreibung\n123")
        click_on("OK")
      end
      expect(page).to have_content("Der Fehlerbericht wurde gespeichert")

      change_request_content = ChangeRequest.last.content
      expect(change_request_content).to eq(key: "person-other", data: { person_id: "42", description: "Beschreibung\r\n123" })
    end

  end
end