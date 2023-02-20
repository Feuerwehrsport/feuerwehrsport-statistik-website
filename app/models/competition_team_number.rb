# frozen_string_literal: true

class CompetitionTeamNumber < ApplicationRecord
  is_view

  belongs_to :team
  belongs_to :competition
  enum gender: { female: 0, male: 1 }
  scope :gender, ->(gender) { where(gender: CompetitionTeamNumber.genders[gender]) }
end
