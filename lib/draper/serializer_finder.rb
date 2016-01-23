module Draper
  module SerializerFinder
    def to_serializer
      object.to_serializer(self)
    end
  end
end