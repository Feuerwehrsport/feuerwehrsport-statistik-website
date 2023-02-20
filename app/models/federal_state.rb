# frozen_string_literal: true

class FederalState < ApplicationRecord
  default_scope { order(:name) }
  validates :name, :shortcut, presence: true
end
