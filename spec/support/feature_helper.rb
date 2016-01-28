
def sign_in
  visit backend_root_path
  fill_in 'E-Mail-Adresse', with: 'a@a.de'
  fill_in 'Passwort', with: 'asdf1234'
  click_button 'Anmelden'
  expect(page).to have_content 'Erfolgreich angemeldet'
end

def api_sign_in
  visit root_path
  page.execute_script("Fss.post('api_users', { api_user: { name: 'test' } }, function () { $('h1').text('logged_in') });")
  expect(page).to have_content("logged_in")
end