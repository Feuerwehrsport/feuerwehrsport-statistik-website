# frozen_string_literal: true

class EntityMerge < ApplicationRecord
  belongs_to :source, polymorphic: true
  belongs_to :target, polymorphic: true
end
