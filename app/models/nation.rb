class Nation < ActiveRecord::Base
  has_many :people, dependent: :restrict_with_exception

  validates :name, presence: true
end
