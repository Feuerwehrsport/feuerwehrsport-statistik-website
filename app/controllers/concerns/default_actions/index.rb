# frozen_string_literal: true

module DefaultActions::Index
  extend ActiveSupport::Concern

  included do
    before_action :assign_collection_for_index, only: :index
  end

  def index
    send_index_xlsx if request.format.xlsx?
  end

  protected

  def assign_collection_for_index
    assign_collection
  end
end
