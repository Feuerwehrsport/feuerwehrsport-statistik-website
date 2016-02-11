class SuggestionPersonSerializer < ActiveModel::Serializer
  attributes :id, :last_name, :first_name, :gender, :translated_gender, :teams

  def teams
    object.teams.map(&:shortcut)
  end
end
