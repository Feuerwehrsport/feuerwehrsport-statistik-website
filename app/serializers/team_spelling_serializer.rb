class TeamSpellingSerializer < ActiveModel::Serializer
  attributes :team_id, :name, :shortcut
end
