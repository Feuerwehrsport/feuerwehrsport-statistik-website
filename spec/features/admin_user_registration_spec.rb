require 'rails_helper'

describe "registration process", type: :feature do
  let(:email_address) { "test@foobar.de" }
  let(:password) { "12345678asdf" }
  it "registers" do
    visit backend_root_path
    click_on "Registrieren"
    fill_in "E-Mail-Adresse", with: email_address
    fill_in "Name", with: "Testnutzer"
    fill_in "admin_user_password", with: password
    fill_in "Passwort wiederholen", with: password
    click_on "Registrieren"
    expect(page).to have_content("Sie haben sich erfolgreich registriert.")

    visit admin_user_confirmation_path(confirmation_token: AdminUser.last.confirmation_token)
    expect(page).to have_content("Bitte melden Sie sich jetzt an.")
    
    fill_in "E-Mail-Adresse", with: email_address
    fill_in "Passwort", with: password
    within(".form-actions") do
      click_on "Anmelden"
    end
    expect(page).to have_content("Erfolgreich angemeldet")
  end
end