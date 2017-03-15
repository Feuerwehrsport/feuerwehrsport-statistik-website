ActiveRecord::Base.send(:include, ActiveModel::SerializerFinder)
Draper::Decorator.send(:include, Draper::SerializerFinder)