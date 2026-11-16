# frozen_string_literal: true

class EntityMerge < ApplicationRecord
  belongs_to :source, polymorphic: true
  belongs_to :target, polymorphic: true
  schema_validations

  # moves everything of source (person or team) to target and removes source;
  # always: future imports replace the name automatically (spelling)
  def self.merge!(source, target, always: false)
    transaction do
      source.merge_to(target)
      "#{source.class}Spelling".constantize.create_from(target, source) if always
      create!(source:, target:)
      unless source.reload.destroy
        raise ActiveRecord::ActiveRecordError,
              "Could not destroy #{source.class.name.underscore} with id ##{source.id}"
      end
    end
  end
end
