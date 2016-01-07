class TeamSerializer < ActiveModel::Serializer
  attributes :id, :name, :shortcut, :status, :latitude, :longitude, :state, :tile_path

  def tile_path
    object.image.tile.url if object.image.present?
  end
end
