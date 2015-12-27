class TeamSerializer < ActiveModel::Serializer
  attributes :id, :name, :shortcut, :status, :latitude, :longitude, :state
end
