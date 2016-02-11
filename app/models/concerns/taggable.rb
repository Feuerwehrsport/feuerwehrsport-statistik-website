module Taggable
  extend ActiveSupport::Concern
  included do
    has_many :tags, as: :taggable, dependent: :destroy
    accepts_nested_attributes_for :tags, reject_if: :all_blank, allow_destroy: true
  end

  def tag_names
    tags.map(&:name)
  end
end