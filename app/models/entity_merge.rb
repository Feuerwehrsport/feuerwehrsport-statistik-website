class EntityMerge < ActiveRecord::Base
  belongs_to :source, polymorphic: true
  belongs_to :target, polymorphic: true

  validates :source, :target, presence: true
end
