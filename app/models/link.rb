# frozen_string_literal: true

class Link < ApplicationRecord
  belongs_to :linkable, polymorphic: true

  scope :linkable_id, ->(id) { where(linkable_id: id) }
  scope :linkable_type, ->(type) { where(linkable_type: type) }
  schema_validations
end
