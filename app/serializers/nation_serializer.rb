# frozen_string_literal: true
class NationSerializer < ActiveModel::Serializer
  attributes :id, :name, :iso
end
