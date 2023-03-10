# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Backend::Series::Rounds', login: :admin do
  it_behaves_like 'a backend resource controller' do
    let(:kind) { Series::Kind.first || create(:series_kind) }
    let(:resource_name) { :series_round }
    let(:resource_attributes) do
      {
        kind_id: kind.id,
        year: 2016,
        aggregate_type: 'DCup',
      }
    end
  end
end
