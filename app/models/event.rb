class Event < ActiveRecord::Base
  has_many :competitions, dependent: :restrict_with_exception

  validates :name, presence: true

  scope :competition_count, -> do
    select("#{table_name}.*, COUNT(#{Competition.table_name}.id) AS count").
    joins(:competitions).
    group("#{table_name}.id")
  end
end
