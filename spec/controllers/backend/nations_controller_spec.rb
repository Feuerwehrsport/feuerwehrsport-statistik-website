# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Backend::NationsController, type: :controller, login: :sub_admin do
  it_behaves_like 'a backend resource controller' do
    let(:resource_attributes) do
      {
        name: 'England',
        iso: 'en',
      }
    end
  end
end
