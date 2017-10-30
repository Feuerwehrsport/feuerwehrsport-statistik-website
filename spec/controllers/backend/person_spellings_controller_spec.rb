require 'rails_helper'

RSpec.describe Backend::PersonSpellingsController, type: :controller, login: :sub_admin do
  let(:person) { create(:person) }

  it_behaves_like 'a backend resource controller' do
    let(:resource_attributes) do
      {
        first_name: 'Freddy',
        last_name: 'Krüger',
        gender: 'male',
        person_id: person.id,
        official: '1',
      }
    end
  end
end
