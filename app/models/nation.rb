# frozen_string_literal: true
class Nation < ApplicationRecord
  has_many :people, dependent: :restrict_with_exception

  scope :filter_collection, -> { order(:name) }

  validates :name, :iso, presence: true
end
