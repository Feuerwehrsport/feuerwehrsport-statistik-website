class Year < ActiveRecord::View
  scope :with_competitions, -> { joins("INNER JOIN competitions on EXTRACT(YEAR FROM DATE(competitions.date)) = year") }
  scope :competition_count, -> do
    select("#{table_name}.*, COUNT(#{Competition.table_name}.id) AS count").
    with_competitions.
    group("#{table_name}.year")
  end

  def competitions
    competition_ids = Year.with_competitions.where(year: year).select("competitions.id AS competition_id").map(&:competition_id)
    Competition.where(id: competition_ids)
  end

  def to_param
    year.to_i
  end
end
