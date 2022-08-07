class PagesController < ResourceController
  cache_actions :firesport_overview, :legal_notice, :rss, :dashboard, :last_competitions_overview,
                :records, :best_of

  def firesport_overview
    @page_title = 'Feuerwehrsport - verschiedene Angebote'
  end

  def legal_notice
    @page_title = 'Impressum'
  end

  def rss
    @page_title = 'RSS-Feeds'
  end

  def datenschutz
    @page_title = 'Datenschutzerklärung'
  end

  def dashboard
    @page_title = 'Feuerwehrsport - Die große Auswertung'
    @last_competitions = last_competitions(8)
    @people_count = Person.count
    @score_valid_count = Score.valid.count + GroupScore.valid.count
    @score_invalid_count = Score.invalid.count + GroupScore.invalid.count
    @places_count = Place.count
    @events_count = Event.count
    @competitions_count = Competition.count
    @teams_count = Team.count
    @years_count = Year.with_competitions.group(:year).count.to_a.map { |y| [y[0].to_i, y[1]] }.sort_by(&:first).reverse
    @news = NewsArticle.first(2).map(&:decorate)
    @performance_overview_disciplines = Calculation::PerformanceOfYear::Discipline.get(2022, 5).map(&:decorate)
    @charts = Chart::Dashboard.new(context: view_context)
    @wms = WettkampfManager::Instance.all.select(&:current?)
  end

  def last_competitions_overview
    @page_title = 'Neueste Wettkämpfe'
    @last_competitions = last_competitions(100)
  end

  def wettkampf_manager
    @page_title = 'Wettkampf-Manager'
    @wettkampf_manager_versions = WettkampfManager::Version.all
  end

  def records
    @page_title = 'Deutsche Rekorde im Feuerwehrsport'

    @team2  = Team.find(2).decorate
    @team3  = Team.find(3).decorate
    @team15 = Team.find(15).decorate
    @team10 = Team.find(10).decorate
    @team61 = Team.find(61).decorate
    @team167 = Team.find(167).decorate
    @team1869 = Team.find(1869).decorate
    @nation_ru = Nation.find_by(iso: :ru).decorate
    @nation_cz = Nation.find_by(iso: :cz).decorate
  end

  def best_of
    @page_title = 'Die 100 schnellsten Zeiten'
    @discipline_structs = []
    [
      %i[hb female],
      %i[hw female],
      %i[hb male],
      %i[hl female],
      %i[hl male],
      %i[gs female],
      %i[la female],
      %i[la male],
    ].each do |discipline, gender|
      klass = Discipline.group?(discipline) ? GroupScore.regular : Score
      @discipline_structs.push OpenStruct.new(
        discipline: discipline,
        gender: gender,
        scores: klass.best_of(discipline, gender).order(:time).first(100).map(&:decorate),
      )
    end
  end

  def online_anmeldungen
    @page_title = 'Hinweise zu Online-Anmeldungen'
    @registrations_competitions = Registrations::Competition.open.decorate
  end

  def about
    @page_title = 'Statistiken über diese Seite'
    @charts = Chart::About.new(context: view_context)
  end

  protected

  def last_competitions(limit)
    Competition.order(created_at: :desc).order(id: :desc).includes(:place, :event).first(limit).map(&:decorate)
  end
end
