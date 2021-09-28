# frozen_string_literal: true

class ActiveRecord::Base
  class << self
    def has_slug(slug_name, parameterized_by: nil)
      define_singleton_method(:param_column_name)  { slug_name.to_sym }
      define_singleton_method(:slug_origin_column) { parameterized_by ? parameterized_by.to_sym : nil }
      validates slug_name, uniqueness: true, presence: true
      include Slugged
    end
  end

  module Slugged
    extend ActiveSupport::Concern

    included do
      before_validation :assign_default_slug
    end

    def to_param
      send(slug_name)
    end

    protected

    def slug_name
      self.class.param_column_name
    end

    def slug_origin_column
      self.class.slug_origin_column
    end

    def assign_default_slug
      return unless send(slug_name).blank? && slug_origin_column.present?

      slug_template = send(slug_origin_column)
      return if slug_template.blank?

      slug_template = slug_template.parameterize
      i = 2
      until self.class.find_by(slug_name => slug_template).nil?
        slug_template = "#{slug_template}-#{i}"
        i += 1
      end
      send("#{slug_name}=", slug_template)
    end
  end
end
