# frozen_string_literal: true

require 'rails_helper'

describe ArrayValidator do
  let(:model_class) do
    Class.new do
      include ActiveModel::Model

      attr_accessor :plain, :strings, :keys, :custom

      validates :plain, array: true
      validates :strings, array: { of: String, min: 2 }
      validates :keys, array: { in: %w[a b] }
      validates :custom, array: { min: 1, message: 'ist falsch' }

      def self.name
        'ArrayValidatorTestModel'
      end
    end
  end
  let(:model) { model_class.new(plain: [], strings: %w[x y], keys: %w[a], custom: [1]) }

  it 'accepts valid arrays' do
    expect(model).to be_valid
  end

  it 'requires arrays' do
    model.plain = 'foo'
    model.strings = nil
    expect(model).not_to be_valid
    expect(model.errors[:plain]).to eq ['must be an array']
    expect(model.errors[:strings]).to eq ['must be an array']
  end

  it 'checks minimum size' do
    model.strings = ['x']
    expect(model).not_to be_valid
    expect(model.errors[:strings]).to eq ['must contain at least 2 element(s)']
  end

  it 'checks allowed values' do
    model.keys = %w[a c]
    expect(model).not_to be_valid
    expect(model.errors[:keys]).to eq ['must all in ["a", "b"]']
  end

  it 'checks element classes' do
    model.strings = ['x', 1]
    expect(model).not_to be_valid
    expect(model.errors[:strings]).to eq ['must contain only String values']
  end

  it 'reports multiple errors' do
    model.strings = [1]
    expect(model).not_to be_valid
    expect(model.errors[:strings]).to eq ['must contain at least 2 element(s)', 'must contain only String values']
  end

  it 'uses custom message' do
    model.custom = []
    expect(model).not_to be_valid
    expect(model.errors[:custom]).to eq ['ist falsch']

    model.custom = 'foo'
    expect(model).not_to be_valid
    expect(model.errors[:custom]).to eq ['ist falsch']
  end
end
