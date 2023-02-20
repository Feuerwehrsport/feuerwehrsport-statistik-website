# frozen_string_literal: true

module API::Actions::Index
  extend ActiveSupport::Concern

  def index
    success(collection_modulized_name.to_sym => collection.decorate, collection_name: collection_modulized_name)
  end
end
