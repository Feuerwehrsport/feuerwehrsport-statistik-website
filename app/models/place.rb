# frozen_string_literal: true

class Place < ApplicationRecord
  include GeoPosition

  has_many :competitions, dependent: :restrict_with_exception

  validates :name, presence: true
  schema_validations

  default_scope { order(:name) }
  scope :competition_count, -> do
    select("#{table_name}.*, COUNT(#{Competition.table_name}.id) AS count")
      .joins(:competitions)
      .group("#{table_name}.id")
  end
  scope :search, ->(value) do
    search_value = "%#{value}%"
    where('name ILIKE ?', search_value)
  end
  scope :filter_collection, -> { order(:name) }
end
