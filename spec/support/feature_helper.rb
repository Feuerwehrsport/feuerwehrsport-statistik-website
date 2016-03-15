
def sign_in(role=:admin, name=:first)
  visit backend_root_path
  fill_in 'E-Mail-Adresse', with: "#{role}@#{name}.com"
  fill_in 'Passwort', with: 'asdf1234'
  click_button 'Anmelden'
  expect(page).to have_content 'Erfolgreich angemeldet'
end

def api_sign_in
  visit root_path
  page.execute_script("Fss.post('api_users', { api_user: { name: 'test' } }, function () { $('h1').text('logged_in') });")
  expect(page).to have_content("logged_in")
end

def sign_out
  visit destroy_admin_user_session_path
end
