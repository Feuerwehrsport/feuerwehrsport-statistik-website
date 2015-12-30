class Nation < ActiveRecord::Base
  has_many :people, dependent: :restrict_with_exception

  validates :name, :iso, presence: true
end
