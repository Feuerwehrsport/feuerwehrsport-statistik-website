
def sign_in
  visit backend_root_path
  fill_in 'E-Mail-Adresse', with: 'a@a.de'
  fill_in 'Passwort', with: 'asdf1234'
  click_button 'Log in'
  expect(page).to have_content 'Erfolgreich angemeldet'
end