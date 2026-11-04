# frozen_string_literal: true

class FederalState < ApplicationRecord
  default_scope { order(:name) }
  schema_validations
end
