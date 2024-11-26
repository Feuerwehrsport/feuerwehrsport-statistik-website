# frozen_string_literal: true

class TeamCompetition < ApplicationRecord
  is_view

  belongs_to :team
  belongs_to :competition
  skip_schema_validations
end
