# frozen_string_literal: true

class UserSerializer < ActiveModel::Serializer
  attributes :name, :type

  def type
    model = object.try(:decorated?) ? object.object : object
    model.class.name.underscore.dasherize
  end
end
