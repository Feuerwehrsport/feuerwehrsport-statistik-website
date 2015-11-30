class PagesController < ResourceController
  def firesport_overview
    @page_title = "Feuerwehrsport - verschiedene Angebote"
  end

  def legal_notice
    @page_title = "Impressum"
  end

  def dashboard
    @page_title = "Feuerwehrsport - Die große Auswertung"
    @last_competitions = last_competitions(8)
    @people_count = Person.count
    @score_valid_count = Score.valid.count + GroupScore.valid.count
    @score_invalid_count = Score.invalid.count + GroupScore.invalid.count
    @places_count = Place.count
    @events_count = Event.count
    @competitions_count = Competition.count
    @teams_count = Team.count
    @years_count = Year.with_competitions.group(:year).count.to_a.map { |y| [y[0].to_i, y[1]] }.sort_by(&:first).reverse
    @news = News.index_order.first(2)
    @performance_overview_disciplines = Calculation::PerformanceOfYear::Discipline.get(2015, 5).map(&:decorate)
  end

  def last_competitions_overview
    @page_title = "Neueste Wettkämpfe"
    @last_competitions = last_competitions(100)
  end

  protected

  def last_competitions(limit)
    Competition.order(:created_at).includes(:place, :event).last(limit).map(&:decorate)
  end
end