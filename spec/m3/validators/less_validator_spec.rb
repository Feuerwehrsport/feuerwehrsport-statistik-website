# frozen_string_literal: true

require 'rails_helper'

# also covers the subclasses LessOrEqualValidator, GreaterValidator, GreaterOrEqualValidator
RSpec.describe LessValidator do
  def build_model(&)
    Class.new do
      include ActiveModel::Model
      include ActiveModel::Validations

      attr_accessor :value, :limit

      def self.name
        'ValidatorTestModel'
      end

      class_eval(&)
    end
  end

  let(:model) { build_model { validates :value, less: { than: :limit } } }

  it 'accepts smaller values' do
    expect(model.new(value: 1, limit: 2)).to be_valid
  end

  it 'rejects equal and greater values with translated message' do
    record = model.new(value: 2, limit: 2)
    expect(record).not_to be_valid
    expect(record.errors[:value]).to eq ['muss kleiner als Limit sein']
    expect(model.new(value: 3, limit: 2)).not_to be_valid
  end

  it 'rejects nil values' do
    expect(model.new(value: nil, limit: 2)).not_to be_valid
    expect(model.new(value: 1, limit: nil)).not_to be_valid
  end

  context 'with allow_nil' do
    let(:model) { build_model { validates :value, less: { than: :limit, allow_nil: true } } }

    it 'accepts nil values' do
      expect(model.new(value: nil, limit: 2)).to be_valid
      expect(model.new(value: 1, limit: nil)).to be_valid
      expect(model.new(value: 3, limit: 2)).not_to be_valid
    end
  end

  context 'without than option' do
    let(:model) { build_model { validates :value, less: true } }

    it 'raises argument error' do
      expect { model.new(value: 1, limit: 2).valid? }.to raise_error(ArgumentError, /Missing option :than/)
    end
  end

  describe LessOrEqualValidator do
    let(:model) { build_model { validates :value, less_or_equal: { than: :limit } } }

    it 'validates' do
      expect(model.new(value: 2, limit: 2)).to be_valid
      record = model.new(value: 3, limit: 2)
      expect(record).not_to be_valid
      expect(record.errors[:value]).to eq ['muss kleiner oder gleich Limit sein']
    end
  end

  describe GreaterValidator do
    let(:model) { build_model { validates :value, greater: { than: :limit } } }

    it 'validates' do
      expect(model.new(value: 3, limit: 2)).to be_valid
      record = model.new(value: 2, limit: 2)
      expect(record).not_to be_valid
      expect(record.errors[:value]).to eq ['muss größer als Limit sein']
    end
  end

  describe GreaterOrEqualValidator do
    let(:model) { build_model { validates :value, greater_or_equal: { than: :limit } } }

    it 'validates' do
      expect(model.new(value: 2, limit: 2)).to be_valid
      record = model.new(value: 1, limit: 2)
      expect(record).not_to be_valid
      expect(record.errors[:value]).to eq ['muss größer oder gleich Limit sein']
    end
  end
end
