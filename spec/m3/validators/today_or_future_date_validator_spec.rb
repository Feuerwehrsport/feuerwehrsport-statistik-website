# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TodayOrFutureDateValidator do
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

  let(:model) { build_model { validates :value, today_or_future_date: true } }

  around { |example| travel_to(Time.zone.local(2020, 5, 5, 12)) { example.run } }

  it 'accepts today and future dates' do
    expect(model.new(value: Date.new(2020, 5, 5))).to be_valid
    expect(model.new(value: Date.new(2020, 5, 6))).to be_valid
  end

  it 'rejects past dates and non dates' do
    record = model.new(value: Date.new(2020, 5, 4))
    expect(record).not_to be_valid
    expect(record.errors[:value]).to eq ['muss heute oder künftiges Datum sein']
    expect(model.new(value: nil)).not_to be_valid
    expect(model.new(value: Time.current)).not_to be_valid
  end
end
