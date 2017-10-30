require 'rails_helper'

describe 'registration process', type: :feature do
  let(:email_address) { 'test@foobar.de' }
  let(:password) { '12345678asdf' }
  it 'registers' do
    clear_emails
    visit backend_root_path
    click_on 'Registrieren'
    fill_in 'Name', with: 'Testnutzer'
    fill_in 'E-Mail-Adresse', with: email_address
    fill_in 'Passwort', with: password
    fill_in 'Passwortbestätigung', with: password
    save_review_screenshot
    click_on 'Registrieren'
    expect(page).to have_content('Sie haben sich erfolgreich registriert.')
    save_review_screenshot
    click_on 'Abmelden'

    open_email email_address
    expect(current_email).to have_content 'Um Ihre E-Mail-Adresse zu bestätigen'
  end
end
