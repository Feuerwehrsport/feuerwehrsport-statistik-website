class Place < ActiveRecord::Base
  has_many :competitions, dependent: :restrict_with_exception

  validates :name, presence: true

  scope :competition_count, -> do
    select("#{table_name}.*, COUNT(#{Competition.table_name}.id) AS count").
    joins(:competitions).
    group("#{table_name}.id")
  end
  scope :search, -> (value) do
    search_value = "%#{value}%"
    where("name ILIKE ?", search_value)
  end
end
