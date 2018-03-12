require 'rails_helper'

describe 'registration feature', type: :feature, js: true do
  let!(:competition) { create(:registrations_competition, admin_user: create(:admin_user, role: :sub_admin)) }
  let!(:assessment) { create(:registrations_assessment, :la, competition: competition) }

  it 'registers team' do
    sign_in :user
    visit registrations_competition_path(competition)

    first(:link, 'Mannschaft anmelden').click
    expect(page).to have_content('Geschlecht wählen')
    within('.template', text: 'männlich') do
      save_review_screenshot
      click_on 'Wählen'
    end
    fill_in 'Name', with: 'Team Mecklenburg-Vorpommern'
    fill_in 'Abkürzung', with: 'Team MV'
    fill_in 'Mannschaftsleiter', with: 'Max Mustermann'
    fill_in 'Straße und Hausnummer', with: 'Musterstraße 123'
    fill_in 'Postleitzahl', with: '98765'
    fill_in 'Ort', with: 'Musterstadt'
    fill_in 'Telefonnummer', with: '+1233/234432'
    fill_in 'E-Mail-Adresse', with: 'foo@bar.de'
    save_review_screenshot
    check 'Löschangriff nass'
    click_on 'Mannschaft anlegen'

    expect(page).to have_content('Max Mustermann')
    expect(page).to have_content('Musterstraße 123')
    expect(page).to have_content('98765')
    expect(page).to have_content('Musterstadt')
    expect(page).to have_content('+1233/234432')
    expect(page).to have_content('foo@bar.de')
  end
end
