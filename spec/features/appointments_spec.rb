require 'rails_helper'

describe "appointments", type: :feature, js: true do
  it "works" do
    api_sign_in

    visit appointments_path
    find("#add-appointment").click
    within('.fss-window') do
      expect(page).to have_content("Termin hinzufügen")
      fill_in "Name", with: "Wintertraining_xyz"
      fill_in "Beschreibung", with: "Beschreibung"
      select('Charlottenthal', from: 'Ort')
      select('D-Cup', from: 'Typ')
      check("Feuerwehrstafette")
      click_on("OK")
    end
    expect(page).to_not have_content("Bitte warten")
    expect(page).to have_content("Wintertraining_xyz")
    expect(Appointment.where(name: "Wintertraining_xyz").count).to eq 1
  end
end