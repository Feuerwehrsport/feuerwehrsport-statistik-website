# frozen_string_literal: true

class ScoreTypeSerializer < ActiveModel::Serializer
  attributes :id, :people, :run, :score
end
