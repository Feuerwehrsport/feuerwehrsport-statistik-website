class FederalState < ActiveRecord::Base
  default_scope { order(:name) }
  validates :name, :shortcut, presence: true
end
