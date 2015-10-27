module PlacesHelper
  def week_overview_chart
    (1..7).map { |wday| @competitions.select { |c| c.date.wday == (wday%7) }.count }
  end
  def year_overview_chart
    (1..12).map { |month| @competitions.select { |c| c.date.month == month }.count }
  end
end