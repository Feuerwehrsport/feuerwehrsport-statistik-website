# frozen_string_literal: true

class PagesController < ResourceController
  cache_actions :firesport_overview, :legal_notice, :dashboard, :last_competitions_overview,
                :records, :best_of

  def firesport_overview
    @page_title = 'Feuerwehrsport kennenlernen'
  end

  def legal_notice
    @page_title = 'Impressum'
  end

  def datenschutz
    @page_title = 'Datenschutzerklärung'
  end

  def dashboard
    @page_title = 'Feuerwehrsport – die große Auswertung'
    @last_competitions = last_competitions(8)
    @years_count = Year.with_competitions.group(:year).count.to_a.map { |y| [y[0].to_i, y[1]] }.sort_by(&:first).reverse
    @best_of_year = Date.current.year
    @best_of_year -= 1 if Date.current.month < 6
  end

  def last_competitions_overview
    @page_title = 'Neueste Wettkämpfe'
    @last_competitions = last_competitions(100)
  end

  def records
    @page_title = 'Deutsche Rekorde im Feuerwehrsport'
    @records = Records.load
  end

  def best_of
    @page_title = 'Die 100 schnellsten Zeiten'
  end

  def about
    @page_title = 'Statistiken über diese Seite'
  end

  protected

  def last_competitions(limit)
    Competition.order(created_at: :desc).order(id: :desc).includes(:place, :event).first(limit).map(&:decorate)
  end
end
