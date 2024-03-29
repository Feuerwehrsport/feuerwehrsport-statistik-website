# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Backend::GroupScoreTypes', login: :sub_admin do
  it_behaves_like 'a backend resource controller' do
    let(:resource_attributes) do
      {
        name: 'WKO',
        regular: '1',
        discipline: 'la',
      }
    end
  end
end
