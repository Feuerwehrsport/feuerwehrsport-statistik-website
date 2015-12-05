class Link < ActiveRecord::Base
  belongs_to :linkable, polymorphic: true

  validates :label, :url, :linkable, presence: true
end
