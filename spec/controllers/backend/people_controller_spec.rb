# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Backend::PeopleController, type: :controller, login: :sub_admin do
  let(:nation) { Nation.first || create(:nation) }

  it_behaves_like 'a backend resource controller' do
    let(:resource_attributes) do
      {
        first_name: 'Freddy',
        last_name: 'Krüger',
        gender: 'male',
        nation_id: nation.id,
      }
    end
  end
end
