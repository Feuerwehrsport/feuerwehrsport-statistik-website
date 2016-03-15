require 'rails_helper'

describe "signin process", type: :feature do
  it "signs in" do
    sign_in
  end

  context "when credentials are wrong" do
    it "then sign in fails" do
      visit backend_root_path
      fill_in 'E-Mail-Adresse', with: 'a@a.de'
      fill_in 'Passwort', with: 'asdf12345'
      click_button 'Anmelden'
      expect(page).to have_content 'E-Mail-Adresse oder Passwort ungültig'
    end
  end
end