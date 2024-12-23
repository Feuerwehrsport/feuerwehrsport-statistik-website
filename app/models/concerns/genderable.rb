# frozen_string_literal: true

module Genderable
  GENDER_KEYS = %i[female male].freeze
  GENDERS = { female: 0, male: 1 }.freeze
  extend ActiveSupport::Concern
  included do
    enum :gender, GENDERS
    scope :gender, ->(gender) { where(gender: GENDERS[gender.to_sym]) }
    scope :order_by_gender, ->(gender) do
      order(gender: gender.to_s == 'female' ? :asc : :desc) if gender.to_s.in?(%w[female male])
    end
  end

  class_methods do
    def gender_string?(string)
      GENDERS[string.try(:to_sym)].present?
    end
  end
end
