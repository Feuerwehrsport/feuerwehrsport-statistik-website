# frozen_string_literal: true

class CompetitionTeamNumber < ApplicationRecord
  is_view

  belongs_to :team
  belongs_to :competition
  enum :gender, { female: 0, male: 1 }, prefix: true
  scope :gender, ->(gender) {
    if gender.in?([:female, 'female', 0])
      where(gender: 0)
    elsif gender.in?([:male, 'male', 1])
      where(gender: 1)
    else
      where(gender: -1)
    end
  }
  skip_schema_validations
end
