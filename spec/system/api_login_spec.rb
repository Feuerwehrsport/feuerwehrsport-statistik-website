# frozen_string_literal: true

require 'rails_helper'

describe 'anonymous login' do
  it 'shows the login window again after a wrong answer' do
    visit root_path
    page.execute_script("Fss.login(function () { $('h1').text('logged_in') });")
    within('.fss-window') do
      question = find('label', text: /\A\d+ (plus|minus|mal) \d+\z/).text
      fill_in question, with: '-1'
      fill_in 'Name', with: 'test'
      click_on 'OK'
    end

    within('.fss-window') do
      expect(page).to have_text('Die Antwort ist nicht korrekt.')
      expect(page).to have_field('Name', with: 'test')
    end
    expect(ApiUser.count).to eq 0

    api_sign_in
    expect(ApiUser.last.name).to eq 'test'
  end
end
