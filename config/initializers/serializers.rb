ActiveModel::Serializer.root = false
ActiveRecord::Base.send(:include, ActiveModel::SerializerFinder)
Draper::Decorator.send(:include, Draper::SerializerFinder)