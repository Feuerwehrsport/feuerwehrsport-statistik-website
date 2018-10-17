module ActiveModel
  module SerializerFinder
    extend ActiveSupport::Concern
    class_methods do
      def serializer_class
        classes = ancestors - included_modules
        classes.each do |klass|
          return "#{klass.name}Serializer".constantize
        rescue NameError
        end
        nil
      end
    end

    def to_serializer(object = self)
      klass = self.class.serializer_class
      klass.nil? ? object : klass.new(object)
    end
  end
end
