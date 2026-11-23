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
  scope :unchecked, -> { where(checked_at: nil) }

  # positions of the teams that started at the competitions of this place
  def team_positions
    team_ids = TeamCompetition.where(competition_id: competitions.select(:id)).select(:team_id)
    Team.positioned.where(id: team_ids).pluck(:latitude, :longitude).map { |lat, lon| [lat.to_f, lon.to_f] }
  end

  # rough position of the place: median of the team positions (robust against teams from far away)
  def estimated_latlon
    positions = team_positions
    return if positions.empty?

    positions.transpose.map { |values| values.sort[values.size / 2] }
  end

  # moves the competitions (and import requests) to the correct place, its position is kept if present
  def merge_to(correct_place)
    raise ActiveRecord::ActiveRecordError, 'same id' if id == correct_place.id

    competitions.update_all(place_id: correct_place.id)
    ImportRequest.where(place_id: id).update_all(place_id: correct_place.id)
    correct_place.update!(latitude:, longitude:) if positioned? && !correct_place.positioned?
  end
end
