# frozen_string_literal: true

class UserSerializer < ActiveModel::Serializer
  attributes :name, :type

  def type
    object.class.name.underscore.dasherize
  end
end
