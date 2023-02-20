# frozen_string_literal: true

class SuggestionTeamSerializer < ActiveModel::Serializer
  attributes :id, :name, :shortcut
end
