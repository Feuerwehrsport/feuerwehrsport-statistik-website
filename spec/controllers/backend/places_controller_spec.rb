require 'rails_helper'

RSpec.describe Backend::PlacesController, type: :controller, login: :sub_admin do
  it_behaves_like 'a backend resource controller' do
    let(:resource_attributes) { { name: 'Charlottenthal' } }
  end
end
