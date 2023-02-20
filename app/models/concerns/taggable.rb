# frozen_string_literal: true

module Taggable
  extend ActiveSupport::Concern
  included do
    has_many :tags, as: :taggable, dependent: :destroy
    accepts_nested_attributes_for :tags, reject_if: :all_blank, allow_destroy: true
  end

  def tag_names
    tags.map(&:name)
  end

  def tag_names=(names)
    new_names = []
    names.each do |name|
      next if name.blank?

      tags.new(name: name, taggable: self) unless tag_names.include?(name)
      new_names.push(name)
    end

    tags.each do |tag|
      tag.mark_for_destruction unless tag.name.in?(new_names)
    end
  end
end
