class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def to_serializer(object = self)
    klass = ActiveModel::Serializer.get_serializer_for(self.class)
    klass.nil? ? object : klass.new(object)
  end
end
