# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FutureTimeValidator do
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

  let(:model) { build_model { validates :value, future_time: true } }

  around { |example| travel_to(Time.zone.local(2020, 5, 5, 12)) { example.run } }

  it 'accepts future times' do
    expect(model.new(value: 1.minute.from_now)).to be_valid
  end

  it 'rejects past times and non times' do
    record = model.new(value: 1.minute.ago)
    expect(record).not_to be_valid
    expect(record.errors[:value]).to eq ['muss künftiger Zeitpunkt sein']
    expect(model.new(value: nil)).not_to be_valid
    expect(model.new(value: 'tomorrow')).not_to be_valid
  end
end
