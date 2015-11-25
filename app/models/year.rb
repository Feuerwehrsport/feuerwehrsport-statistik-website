class Year < ActiveRecord::View
  scope :with_competitions, -> { joins("INNER JOIN competitions on EXTRACT(YEAR FROM DATE(competitions.date)) = year") }
end
