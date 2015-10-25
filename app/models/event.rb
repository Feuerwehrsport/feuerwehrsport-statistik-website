class Event < ActiveRecord::Base
  has_many :competitions

  validates :name, presence: true
end
