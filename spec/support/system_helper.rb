# frozen_string_literal: true

def sign_in(role = :admin)
  user = create(:admin_user, role)
  visit new_session_path
  fill_in 'E-Mail-Adresse', with: user.email_address

  fill_in 'Passwort', with: 'Secret123'
  click_button 'Anmelden' # the footer has a link with the same text
  expect(page).to have_text 'Abmelden'
end

# answers the arithmetic question of the anonymous login like a person
def answer_login_question
  question = find('label', text: /\A\d+ (plus|minus|mal) \d+\z/).text
  a, operation, b = question.split
  fill_in question, with: a.to_i.public_send(ApiLoginChallenge::OPERATIONS.fetch(operation), b.to_i)
end

# anonymous login (Contributions::LoginsController), opened directly instead of in the dialog
def api_sign_in
  visit new_contributions_login_path(return_to: new_contributions_person_path)
  answer_login_question
  fill_in 'Name', with: 'test'
  click_on 'Anmelden'
  expect(page).to have_text('Person hinzufügen')
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
