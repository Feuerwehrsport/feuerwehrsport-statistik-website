require 'rails_helper'

describe "news features", type: :feature, js: true, driver: :webkit do
  it "shows an overview" do
    visit news_index_path
    expect(page).to have_content 'Neuigkeiten'
    expect(page).to have_content 'Neue Seite im Aufbau'
    expect(page).to have_content 'Wertungsgruppen für Wettkämpfe'
    expect(page).to have_content 'Karte bei Wettkampf verfügbar'

    visit news_path(id: 20)
    expect(page).to have_content 'Wettkämpfer werden Nationen zugeordnet'
    expect(page).to have_content 'Neuigkeiten vom 01.09.2014'
  end
end