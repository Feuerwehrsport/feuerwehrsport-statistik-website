# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Backend::ImportRequestsController, type: :controller, login: :sub_admin do
  let(:place) { create(:place) }
  let(:event) { create(:event) }
  let!(:admin) { create(:admin_user, :admin) }

  it_behaves_like 'a backend resource controller' do
    let(:resource_attributes) do
      {
        url: 'http://foobar.com/test',
        place_id: place.id,
        event_id: event.id,
        date: '2013-09-21',
        description: 'Am 21.09.2013 fand das Finale des Deutschland-Cups in Charlottenthal statt.',
      }
    end
  end
end
