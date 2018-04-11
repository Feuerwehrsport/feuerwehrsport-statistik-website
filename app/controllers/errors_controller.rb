class ErrorsController < ApplicationController
  before_action :old_path_redirects
  before_action :entity_merge_redirects

  OLD_PATHS = [
    [%r{^/page/administration\.html$}, '/backend'],
    [%r{^/page/best-of\.html$}, '/best_of'],
    [%r{^/page/best-performance-of-year-(\d+)\.html$}, '/years/%1%/best_scores'],
    [%r{^/page/best-scores-of-year-(\d+)\.html$}, '/years/%1%/best_performance'],
    [%r{^/page/competition-(\d+)\.html$}, '/competitions/%1%'],
    [%r{^/page/competitions\.html$}, '/competitions'],
    [%r{^/page/date-(\d+)\.html$}, '/appointments/%1%'],
    [%r{^/page/dates\.html$}, '/appointments'],
    [%r{^/page/event-(\d+)\.html$}, '/events/%1%'],
    [%r{^/page/events\.html$}, '/events'],
    [%r{^/page/feeds\.html$}, '/rss'],
    [%r{^/page/feuerwehrsport\.html$}, '/feuerwehrsport'],
    [%r{^/page/home\.html$}, '/'],
    [%r{^/page/last-competitions\.html$}, '/last_competitions'],
    [%r{^/page/logs\.html$}, '/change_logs'],
    [%r{^/page/news-(\d+)\.html$}, '/news/%1%'],
    [%r{^/page/news\.html$}, '/news'],
    [%r{^/page/person-(\d+)\.html$}, '/people/%1%'],
    [%r{^/page/persons\.html$}, '/people'],
    [%r{^/page/place-(\d+)\.html$}, '/places/%1%'],
    [%r{^/page/places\.html$}, '/places'],
    [%r{^/page/records\.html$}, '/records'],
    [%r{^/page/team-(\d+)\.html$}, '/teams/%1%'],
    [%r{^/page/teams\.html$}, '/teams'],
    [%r{^/page/wettkampf-manager\.html$}, '/wettkampf_manager'],
    [%r{^/page/year-(\d+)\.html$}, '/years/%1%'],
    [%r{^/page/years\.html$}, '/years'],
    [%r{^/news/(\d+)$}, '/news_articles/%1%'],
    [%r{^/news/?$}, '/news_articles'],
    [%r{^/news\.atom$}, '/news_articles.atom'],
  ].freeze

  def not_found
    @page_title = '404 - Seite nicht gefunden'
    render(status: 404)
  end

  def internal_server_error
    @page_title = '500 - Interner Fehler'
    render(status: 500)
  end

  def unacceptable
    @page_title = '422 - Nicht verarbeitbare Werte'
    render(status: 422)
  end

  protected

  def original_fullpath
    request.env['ORIGINAL_FULLPATH']
  end

  def redirect_with_log(target, log_message)
    logger.info("ERROR_CONTROLLER_REDIRECT_INFO[#{log_message}]: #{original_fullpath}  [->]  #{target}")
    redirect_to(target, status: :moved_permanently)
  end

  def entity_merge_redirects
    current_path = original_fullpath || return
    match = current_path.match(%r{^/(?<table>people|teams)/(?<id>\d+)$})
    if match
      entity_merge = EntityMerge.where(source_type: match[:table].singularize.classify, source_id: match[:id]).first
    end
    redirect_with_log(url_for(entity_merge.target), :entity_merge_redirects) if entity_merge
  end

  def old_path_redirects
    current_path = original_fullpath || return
    OLD_PATHS.each do |regexp, old_path|
      old_path_match = OldPathMatch.new(regexp, old_path, current_path)
      redirect_with_log(old_path_match.redirect_target, :old_path_redirects) if old_path_match.match?
    end
  end

  OldPathMatch = Struct.new(:regexp, :new_path, :current_path) do
    def match?
      match.present?
    end

    def match
      @match ||= current_path.match(regexp)
    end

    def redirect_target
      (1..(match.length - 1)).each do |i|
        self.new_path = new_path.gsub("%#{i}%", match[i])
      end
      new_path
    end
  end
end
