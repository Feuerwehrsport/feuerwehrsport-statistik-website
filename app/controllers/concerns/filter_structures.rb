# frozen_string_literal: true

module FilterStructures
  extend ActiveSupport::Concern

  included do
    helper_method :m3_filter_structure
  end

  class_methods do
    def filter_index(&)
      define_method(:m3_filter_structure) do
        @m3_filter_structure ||= begin
          f = M3::Filter::Structure::Builder.new
          instance_exec(f, &)
          f.structure.decorate
        end
      end
    end
  end

  protected

  def m3_filter_structure
    f = M3::Filter::Structure::Builder.new
    f.structure.decorate
  end
end
