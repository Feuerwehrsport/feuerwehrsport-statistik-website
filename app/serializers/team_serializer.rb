# frozen_string_literal: true

class TeamSerializer < ActiveModel::Serializer
  attributes :id, :name, :shortcut, :status, :latitude, :longitude, :state, :tile_path, :best_scores

  def tile_path
    object.image.tile.url if object.image.present?
  end
end
