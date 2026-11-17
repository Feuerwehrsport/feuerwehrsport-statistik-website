# frozen_string_literal: true

require 'rails_helper'

describe 'anonymous login' do
  it 'shows the login again after a wrong answer and keeps the input' do
    visit people_path
    click_on 'Person hinzufügen'

    within('dialog.contribution-dialog') do
      fill_in find('label', text: /\A\d+ (plus|minus|mal) \d+\z/).text, with: '-1'
      fill_in 'Name', with: 'test'
      click_on 'Anmelden'

      expect(page).to have_text('Die Antwort ist nicht korrekt.')
      expect(page).to have_field('Name', with: 'test')
      expect(ApiUser.count).to eq 0

      answer_login_question
      click_on 'Anmelden'
      expect(page).to have_text('Person hinzufügen')
    end
    expect(ApiUser.last.name).to eq 'test'
  end
end
