# frozen_string_literal: true

module FilterStructures
  extend ActiveSupport::Concern

  included do
    helper_method :filter_structure
  end

  class_methods do
    def filter_index(&)
      define_method(:filter_structure) do
        @filter_structure ||= begin
          f = Ui::Filter::Structure::Builder.new
          instance_exec(f, &)
          f.structure.decorate
        end
      end
    end
  end

  protected

  def filter_structure
    f = Ui::Filter::Structure::Builder.new
    f.structure.decorate
  end
end
