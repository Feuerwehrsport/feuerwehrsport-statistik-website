class Year < ActiveRecord::Base
  scope :with_competitions, -> { joins("INNER JOIN competitions on EXTRACT(YEAR FROM DATE(competitions.date)) = year") }

  protected

  def readonly?
    true
  end
end
