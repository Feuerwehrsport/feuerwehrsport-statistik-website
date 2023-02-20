# frozen_string_literal: true

module MapSupport
  extend ActiveSupport::Concern

  class_methods do
    def map_support_at(*action_names)
      define_method(:map_support?) do
        action_name.to_sym.in?(action_names)
      end
    end
  end

  included do
    helper_method :map_support?
  end

  def map_support?
    false
  end
end
