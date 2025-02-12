# frozen_string_literal: true

class Year < ApplicationRecord
  is_view

  scope :with_competitions, -> { joins('INNER JOIN competitions on competitions.year = years.year') }
  scope(:competition_count, -> do
    select("years.*, COUNT(#{Competition.table_name}.id) AS count")
      .with_competitions
      .group('years.year')
  end)
  skip_schema_validations

  def self.param_column_name
    :year
  end

  def competitions
    Competition.where(id: Year.with_competitions.where(year:).select('competitions.id AS competition_id'))
  end

  def to_param
    year.to_i
  end

  def to_i
    to_param
  end
end
