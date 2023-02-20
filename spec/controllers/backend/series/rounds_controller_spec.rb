# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Backend::Series::RoundsController, type: :controller, login: :admin do
  it_behaves_like 'a backend resource controller' do
    let(:resource_name) { :series_round }
    let(:resource_attributes) do
      {
        name: 'D-Cup',
        slug: 'd-cup',
        year: 2016,
        aggregate_type: 'DCup',
      }
    end
  end
end
