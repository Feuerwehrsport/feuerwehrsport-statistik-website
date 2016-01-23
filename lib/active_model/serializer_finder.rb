module ActiveModel
  module SerializerFinder
    extend ActiveSupport::Concern
    class_methods do
      def serializer_class
        classes = ancestors - included_modules
        classes.each do |klass|
          begin
            return "#{klass.name}Serializer".constantize
          rescue NameError
          end
        end
        nil
      end
    end

    def to_serializer(object=self)
      klass = self.class.serializer_class
      klass.nil? ? object : klass.new(object)
    end
  end
end