require 'rails_helper'

describe "backend resources", type: :feature do
  it "works" do
    sign_in
    Backend::ResourcesController.models.each do |model_class|
      # index
      visit url_for([:backend, model_class])
      expect(page.find("h1")).to have_content model_class.model_name.human(count: 0)
      expect(page.find(".breadcrumb")).to have_content 'Übersicht'

      # new
      visit url_for(action: :new, controller: "backend/#{model_class.name.tableize}")
      expect(page.find("h1")).to have_content model_class.model_name.human(count: 1)
      expect(page.find(".breadcrumb")).to have_content 'Hinzufügen'

      # show
      visit url_for(action: :show, controller: "backend/#{model_class.name.tableize}", id: model_class.first.id)
      expect(page.find("h1")).to have_content model_class.model_name.human(count: 1)
      expect(page.find(".breadcrumb")).to have_content 'Anzeigen'

      # edit
      visit url_for(action: :edit, controller: "backend/#{model_class.name.tableize}", id: model_class.first.id)
      expect(page.find("h1")).to have_content model_class.model_name.human(count: 1)
      expect(page.find(".breadcrumb")).to have_content 'Bearbeiten'
    end
  end
end