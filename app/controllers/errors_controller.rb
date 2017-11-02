class ErrorsController < ApplicationController
  before_action :old_path_redirects
  before_action :entity_merge_redirects

  OLD_PATHS = [
    [/^\/page\/administration\.html$/, '/backend'],
    [/^\/page\/best-of\.html$/, '/best_of'],
    [/^\/page\/best-performance-of-year-(\d+)\.html$/, '/years/%1%/best_scores'],
    [/^\/page\/best-scores-of-year-(\d+)\.html$/, '/years/%1%/best_performance'],
    [/^\/page\/competition-(\d+)\.html$/, '/competitions/%1%'],
    [/^\/page\/competitions\.html$/, '/competitions'],
    [/^\/page\/date-(\d+)\.html$/, '/appointments/%1%'],
    [/^\/page\/dates\.html$/, '/appointments'],
    [/^\/page\/event-(\d+)\.html$/, '/events/%1%'],
    [/^\/page\/events\.html$/, '/events'],
    [/^\/page\/feeds\.html$/, '/rss'],
    [/^\/page\/feuerwehrsport\.html$/, '/feuerwehrsport'],
    [/^\/page\/home\.html$/, '/'],
    [/^\/page\/last-competitions\.html$/, '/last_competitions'],
    [/^\/page\/logs\.html$/, '/change_logs'],
    [/^\/page\/news-(\d+)\.html$/, '/news/%1%'],
    [/^\/page\/news\.html$/, '/news'],
    [/^\/page\/person-(\d+)\.html$/, '/people/%1%'],
    [/^\/page\/persons\.html$/, '/people'],
    [/^\/page\/place-(\d+)\.html$/, '/places/%1%'],
    [/^\/page\/places\.html$/, '/places'],
    [/^\/page\/records\.html$/, '/records'],
    [/^\/page\/team-(\d+)\.html$/, '/teams/%1%'],
    [/^\/page\/teams\.html$/, '/teams'],
    [/^\/page\/wettkampf-manager\.html$/, '/wettkampf_manager'],
    [/^\/page\/year-(\d+)\.html$/, '/years/%1%'],
    [/^\/page\/years\.html$/, '/years'],
    [/^\/news\/(\d+)$/, '/news_articles/%1%'],
    [/^\/news\/?$/, '/news_articles'],
    [/^\/news\.atom$/, '/news_articles.atom'],
  ].freeze

  def not_found
    @page_title = '404 - Seite nicht gefunden'
    render(status: 404)
  end

  def internal_server_error
    @page_title = '500 - Interner Fehler'
    render(status: 500)
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
    match = current_path.match(/^\/(?<table>people|teams)\/(?<id>\d+)$/)
    entity_merge = EntityMerge.where(source_type: match[:table].singularize.classify, source_id: match[:id]).first if match
    redirect_with_log(url_for(entity_merge.target), :entity_merge_redirects) if entity_merge
  end

  def old_path_redirects
    current_path = original_fullpath || return
    OLD_PATHS.each do |regexp, old_path|
      old_path_match = OldPathMatch.new(regexp, old_path, current_path)
      redirect_with_log(old_path_match.redirect_target, :old_path_redirects) if old_path_match.match?
    end
  end

  class OldPathMatch < Struct.new(:regexp, :new_path, :current_path)
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
