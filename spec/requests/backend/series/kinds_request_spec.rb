# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Backend::Series::Kinds', login: :admin do
  it_behaves_like 'a backend resource controller' do
    let(:resource_name) { :series_kind }
    let(:resource_attributes) do
      {
        name: 'D-Cup',
        slug: 'd-cup',
      }
    end
  end
end
