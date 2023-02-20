# frozen_string_literal: true
class SuggestionPersonSerializer < ActiveModel::Serializer
  attributes :id, :last_name, :first_name, :gender, :gender_translated, :teams

  def teams
    object.teams.map(&:shortcut)
  end
end
