# frozen_string_literal: true

module M3::CallbackHelpers
  extend ActiveSupport::Concern

  class_methods do
    def before_action_once(name, *arguments)
      before_action(name, *arguments) unless name.in?(get_callbacks(:process_action).map(&:filter))
    end
  end
end
