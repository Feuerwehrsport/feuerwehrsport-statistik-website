# frozen_string_literal: true
class Series::RoundSerializer < ActiveModel::Serializer
  attributes :id, :name, :year, :aggregate_type, :full_cup_count, :official
end
