require 'rails_helper'

describe "news features", type: :feature, js: true do
  it "shows an overview" do
    visit news_index_path
    expect(page).to have_content 'Neuigkeiten'
    expect(page).to have_content 'Löschangriff Position anzeigen'
    expect(page).to have_content '100 Wettkämpfe eingetragen'

    visit news_path(id: 13)
    expect(page).to have_content '100 Wettkämpfe eingetragen'
    expect(page).to have_content 'Neuigkeiten vom 30.03.2013'
  end
end