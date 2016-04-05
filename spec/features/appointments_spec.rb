require 'rails_helper'

describe "appointments", type: :feature, js: true do
  it "can add appointment and edit one" do
    api_sign_in

    # add one
    visit appointments_path
    find("#add-appointment").click
    within('.fss-window') do
      expect(page).to have_content("Termin hinzufügen")
      fill_in "Name", with: "Wintertraining_xyz"
      fill_in "Beschreibung", with: "Beschreibung\n123"
      select('Charlottenthal', from: 'Ort')
      select('D-Cup', from: 'Typ')
      check("Feuerwehrstafette")
      click_on("OK")
    end
    expect(page).to_not have_content("Bitte warten")
    expect(page).to have_content("Wintertraining_xyz")

    appointment = Appointment.where(name: "Wintertraining_xyz")
    expect(appointment.count).to eq 1
    expect(appointment.first.attributes.symbolize_keys).to include(
      name: "Wintertraining_xyz",
      dated_at: Date.today,
      description: "Beschreibung\n123",
      disciplines: "fs",
      event_id: 1,
      place_id: 1,
    )

    # edit one
    click_on("Wintertraining_xyz")
    find('#edit-appointment').click
    within('.fss-window') do
      expect(find_field('Name').value).to eq "Wintertraining_xyz"
      expect(find_field("Beschreibung").value).to eq "Beschreibung\n123"
      fill_in "Name", with: "Wintertraining_opü"
      fill_in "Beschreibung", with: "Beschreibung\n890"
      select('Tribsees', from: 'Ort')
      select('MV-Cup', from: 'Typ')
      check("Hakenleitersteigen")
      click_on("OK")
    end
    expect(page).to have_content("Der Fehlerbericht wurde gespeichert")


    change_request_content = ChangeRequest.last.content
    expect(change_request_content).to include key: "appointment-edit"
    expect(change_request_content[:data][:appointment]).to eq( 
      name: "Wintertraining_opü",
      dated_at: Date.today.to_s,
      description: "Beschreibung\r\n890",
      disciplines: "fs,hl",
      event_id: "13",
      place_id: "3",
    )
  end
end