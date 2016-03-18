require 'rails_helper'

describe "create competition", type: :feature, js: true do
  it "registers" do
    sign_in(:user)

    click_on "Anmelden"
    click_on "Wettkampfanmeldungen"
    click_on "Neuen Wettkampf anlegen"
    expect(page).to have_content("Vorlage für Wettkämpf wählen")

    within('.template:nth-child(5)') do
      click_on "Als Vorlage wählen"
    end

    expect(find_field('comp_reg_competition_name').value).to eq "Deutschland-Cup"
    fill_in "Datum", with: "29.02.2016"
    fill_in "Ort", with: "Ostseebad Nienhagen"
    click_on "Wettkampf anlegen"

    expect(page).to have_content("Wettkampf ist noch nicht öffentlich")
    expect(page).to have_content("Eine lange Beschreibung")

    # click_on "Veröffentlichen"
    # check "Veröffentlichen"
    # click_on "Wettkampf speichern"

    # expect(page).to_not have_content("Wettkampf ist noch nicht öffentlich")

    # first(:link, "Mannschaft anmelden").click 
    # expect(page).to have_content("Wettkampfanmeldung")
    # expect(page).to have_content("Daten der Mannschaft")
    # click_on "Deutschland-Cup - 29.02.2016"

    # first(:link, "Wettkämpfer anmelden").click 
    # expect(page).to have_content("Schnelleingabe")
    # expect(page).to have_content("Zusätzliche Angaben")
    # click_on ".close"

    #sign_out
  end
end