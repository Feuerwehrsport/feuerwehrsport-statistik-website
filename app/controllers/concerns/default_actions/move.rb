# frozen_string_literal: true

module DefaultActions::Move
  extend ActiveSupport::Concern

  included do
    before_action :assign_resource_for_move, only: :move
  end

  def move; end

  protected

  def assign_resource_for_move
    assign_resource
  end
end
