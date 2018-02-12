require 'rails_helper'

describe 'ipo', type: :feature do
  context 'when registration is open' do
    before do
      allow_any_instance_of(Ipo::RegistrationsController).to receive(:registration_open?).and_return(true)
      clear_emails
    end

    it 'registers' do
      visit new_ipo_registration_path
      expect(page).to have_content('Inselpokal-Anmeldung')

      find('input[type=submit]').click
      expect(page).to have_content('muss ausgefüllt werden')
      save_review_screenshot

      fill_in 'Nachname, Vorname', with: 'Meier, Alfred'
      fill_in 'Ort', with: 'Rostock'
      fill_in 'E-Mail-Adresse', with: 'alfred@meier.de'
      fill_in 'Telefonnummer', with: '0162/8129970'
      fill_in 'Name der Mannschaft', with: 'Warin'

      check 'Frauenmannschaft'
      check 'Jugendmannschaft'
      find('input#ipo_registration_terms_of_service').click
      find('input[type=submit]').click

      expect(page).to have_content('Deine Anmeldung zum Inselpokal')
      save_review_screenshot

      open_email 'alfred@meier.de'
      expect(current_email).to have_content 'Dies ist eine Bestätigung für deine Anmeldung zum Inselpokal Poel.'
    end
  end
  context 'when registration is closed' do
    before do
      allow_any_instance_of(Ipo::RegistrationsController).to receive(:registration_open?).and_return(false)
    end

    it 'registers' do
      visit new_ipo_registration_path
      expect(page).to have_content('Deine Anmeldung zum Inselpokal ist zur Zeit nicht möglich.')
      save_review_screenshot
      expect(page).to have_content('Datum des Inselpokals')
    end
  end
end
