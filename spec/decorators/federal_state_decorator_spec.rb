# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FederalStateDecorator do
  it 'returns name as string' do
    expect(FederalState.new(name: 'Mecklenburg-Vorpommern', shortcut: 'MV').decorate.to_s)
      .to eq 'Mecklenburg-Vorpommern'
  end
end
