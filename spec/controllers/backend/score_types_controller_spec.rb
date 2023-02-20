# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Backend::ScoreTypesController, type: :controller, login: :sub_admin do
  it_behaves_like 'a backend resource controller' do
    let(:resource_attributes) do
      {
        people: 10,
        run: 8,
        score: 4,
      }
    end
  end
end
