# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Backend::NewsArticlesController, type: :controller, login: :admin do
  let(:admin_user) { create(:admin_user) }

  it_behaves_like 'a backend resource controller' do
    let(:resource_attributes) do
      {
        title: 'Neuigkeiten',
        content: 'Inhalt',
        admin_user_id: admin_user.id,
        published_at: '2017-01-01',
      }
    end
  end
end
