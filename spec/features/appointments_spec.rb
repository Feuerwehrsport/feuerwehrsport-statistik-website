require 'rails_helper'

describe 'appointments', type: :feature, js: true do
  let!(:place) { create(:place) }
  let!(:tribsees) { create(:place, name: 'Tribsees') }
  let!(:event) { create(:event) }
  let!(:mvcup) { create(:event, name: 'MV-Cup') }

  it 'can add appointment and edit one' do
    api_sign_in

    # add one
    visit appointments_path
    find('#add-appointment').click
    within('.fss-window') do
      expect(page).to have_content('Termin hinzufügen')
      fill_in 'Name', with: 'Wintertraining_xyz'
      fill_in 'Beschreibung', with: "Beschreibung\n123"
      select('Charlottenthal', from: 'Ort')
      select('D-Cup', from: 'Typ')
      check('Feuerwehrstafette')
      save_review_screenshot
      click_on('OK')
    end
    expect(page).to_not have_content('Bitte warten')
    expect(page).to have_content('Wintertraining_xyz')

    appointments = Appointment.where(name: 'Wintertraining_xyz')
    expect(appointments.count).to eq 1
    expect(appointments.first.attributes.symbolize_keys).to include(
      name: 'Wintertraining_xyz',
      description: "Beschreibung\n123",
      disciplines: 'fs',
      event_id: event.id,
      place_id: place.id,
    )
    api_sign_out

    api_sign_in
    visit appointments_path

    # edit one
    click_on('Wintertraining_xyz')
    find('#edit-appointment').click
    within('.fss-window') do
      expect(find_field('Name').value).to eq 'Wintertraining_xyz'
      expect(find_field('Beschreibung').value).to eq "Beschreibung\n123"
      fill_in 'Name', with: 'Wintertraining_opü'
      fill_in 'Beschreibung', with: "Beschreibung\n890"
      select('Tribsees', from: 'Ort')
      select('MV-Cup', from: 'Typ')
      check('Hakenleitersteigen')
      click_on('OK')
    end
    expect(page).to_not have_content('Bitte warten')
    expect(page).to have_content('Der Fehlerbericht wurde gespeichert')

    change_request_content = ChangeRequest.last.content
    expect(change_request_content).to include key: 'appointment-edit'
    expect(change_request_content[:data][:appointment]).to include(
      name: 'Wintertraining_opü',
      description: "Beschreibung\r\n890",
      disciplines: 'fs,hl',
      event_id: mvcup.id.to_s,
      place_id: tribsees.id.to_s,
    )
  end
end
