# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EntityMergeDecorator do
  it 'decorates entity merges' do
    entity_merge = EntityMerge.new(source: build(:person), target: build(:person))
    expect(entity_merge.decorate).to be_a described_class
    expect(entity_merge.decorate.source).to eq entity_merge.source
  end
end
