# frozen_string_literal: true

def sign_in(role = :admin)
  user = create(:admin_user, role)
  visit new_session_path
  fill_in 'E-Mail-Adresse', with: user.email_address

  fill_in 'Passwort', with: 'Secret123'
  click_link_or_button 'Anmelden'
  expect(page).to have_text 'Sie sind angemeldet'
end

# fills the anonymous login window like a person: reads the arithmetic question and answers it
def api_sign_in
  visit root_path
  page.execute_script("Fss.login(function () { $('h1').text('logged_in') });")
  within('.fss-window') do
    question = find('label', text: /\A\d+ (plus|minus|mal) \d+\z/).text
    a, operation, b = question.split
    fill_in question, with: a.to_i.public_send(ApiLoginChallenge::OPERATIONS.fetch(operation), b.to_i)
    fill_in 'Name', with: 'test'
    click_on 'OK'
  end
  expect(page).to have_text('logged_in')
end

def api_sign_out
  visit root_path
  page.execute_script("Fss.post('api_users/logout', {}, function () { $('h1').text('logged_out') });")
  expect(page).to have_text('logged_out')
end

def sign_out
  within('#footer') do
    click_on('Anmelden')
  end
  click_on('Ausloggen')
  expect(page).to have_text('Erfolgreich abgemeldet')
end
