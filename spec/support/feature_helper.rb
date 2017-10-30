
def sign_in(role = :admin, name = :first)
  visit new_session_path
  fill_in 'E-Mail-Adresse', with: "#{role}@#{name}.com"
  fill_in 'Passwort', with: 'asdf1234'
  click_button 'Anmelden'
  expect(page).to have_content 'Erfolgreich angemeldet'
end

def api_sign_in
  visit root_path
  page.execute_script("Fss.post('api_users', { api_user: { name: 'test' } }, function () { $('h1').text('logged_in') });")
  expect(page).to have_content('logged_in')
end

def api_sign_out
  visit root_path
  page.execute_script("Fss.post('api_users/logout', {}, function () { $('h1').text('logged_out') });")
  expect(page).to have_content('logged_out')
end

def sign_out
  within('#footer') do
    click_on('Anmelden')
  end
  click_on('Ausloggen')
  expect(page).to have_content('Erfolgreich abgemeldet')
end
