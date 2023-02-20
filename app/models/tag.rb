# frozen_string_literal: true

class Tag < ApplicationRecord
  belongs_to :taggable, polymorphic: true
end
