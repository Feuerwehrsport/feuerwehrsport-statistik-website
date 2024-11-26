# frozen_string_literal: true

class SingleDiscipline < ApplicationRecord
  has_many :scores
  schema_validations
end
