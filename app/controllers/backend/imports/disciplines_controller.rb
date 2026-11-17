# frozen_string_literal: true

# import of the results of one discipline into a competition, rendered in the turbo frame "import-discipline":
# input (columns, separator, lines) -> check (preview with corrections) -> create (scores)
class Backend::Imports::DisciplinesController < Backend::BackendController
  include ChangeLogging

  COLUMNS = %w[last_name first_name given_person_id team run given_team_id given_team_number time col].freeze
  SEPARATORS = { 'TAB' => "\t", ',' => ',', '|' => '|' }.freeze
  # headlines of the result rows of import requests (Feusport)
  HEADLINE_COLUMNS = {
    'Vorname' => 'first_name', 'Nachname' => 'last_name', 'statistik_person_id' => 'given_person_id',
    'Mannschaft' => 'team', 'statistik_team_id' => 'given_team_id', 'statistik_team_number' => 'given_team_number',
    'Lauf' => 'run', 'time' => 'time'
  }.freeze

  layout false
  before_action :authorize_import
  before_action :assign_input

  def new
    import_rows_from_request if params[:import_request_id].present?
    render :new
  end

  def check
    separator = SEPARATORS.fetch(@separator)
    @check = Import::Check.new(discipline: @discipline, gender: @gender, raw_lines: @raw_lines, separator:,
                               raw_headline_columns: @columns.join(separator))
    return render(:new, status: :unprocessable_content) unless @check.valid?

    @check.import_lines!
    assign_target_options
    render :check
  end

  # missing team of the preview: create it and check again
  def team
    team = Team.new(params.expect(team: %i[name shortcut status]))
    authorize!(:create, team)
    unless Team.transaction { team.save && log_change(team, serializer: TeamSerializer) }
      @team_error = "#{team.name}: #{team.errors.full_messages.to_sentence}"
    end
    check
  end

  def create
    scores = selected_scores
    return render_create_error('Keine gültigen Zeilen ausgewählt.') if scores.empty?

    import = Import::Scores.new(discipline: @discipline, gender: @gender, competition_id: @competition.id,
                                scores:, single_discipline_id: params[:single_discipline_id])
    ActiveRecord::Base.transaction do
      import.group_score_category_id = group_score_category_id if Discipline.group?(@discipline)
      raise ActiveRecord::RecordInvalid, import unless import.valid?

      import.save!
      ChangeLog.create!(model_class: Import::Scores, user: current_user, action: 'scores-import-scores',
                        after_hash: { discipline: @discipline, gender: @gender, competition_id: @competition.id,
                                      group_score_category_id: import.group_score_category_id,
                                      single_discipline_id: import.single_discipline_id, scores: })
    end
    clean_cache
    @count = scores.sum { |score| score[:times].size }
    render :created
  rescue ActiveRecord::RecordInvalid => e
    render_create_error(e.message)
  end

  private

  def authorize_import
    authorize!(:create, Import::Scores)
    authorize!(:create, GroupScore)
    authorize!(:create, Score)
  end

  def assign_input
    @competition = Competition.find(params[:competition_id]).decorate
    @discipline = params[:discipline].to_s.presence_in(Discipline::WITHOUT_DOUBLE_EVENT.map(&:to_s)) ||
                  raise(ActiveRecord::RecordNotFound)
    @gender = params[:gender].to_s.presence_in(%w[female male]) || raise(ActiveRecord::RecordNotFound)
    @separator = params[:separator].presence_in(SEPARATORS.keys) || 'TAB'
    @columns = Array(params[:columns]).select { |column| column.in?(COLUMNS) }.presence || default_columns
    @raw_lines = params[:raw_lines].to_s
  end

  def default_columns
    case @discipline
    when 'hl', 'hb' then %w[last_name first_name team time time]
    when 'la' then %w[team time time]
    when 'gs' then %w[team time]
    when 'fs' then %w[team time run]
    end
  end

  # rows of a direct import of an import request: first row is the headline
  def import_rows_from_request
    import_request = ImportRequest.find(params[:import_request_id])
    authorize!(:update, import_request)
    rows = import_request.import_data_results[params[:result_index].to_i]&.dig(:rows) || []
    headline, *lines = rows
    @columns = Array(headline).map { |column| HEADLINE_COLUMNS.fetch(column.to_s, 'col') }.presence || @columns
    @raw_lines = lines.map { |line| line.join("\t") }.join("\n")
    @separator = 'TAB'
  end

  # lines of the preview form that are marked as valid
  def selected_scores
    params.fetch(:lines, {}).values.filter_map do |line|
      next unless line[:valid] == '1'

      score = line.permit(:team_number, :team_id, :run, :person_id, :last_name, :first_name, times: []).to_h
                  .symbolize_keys.compact_blank
      score[:times] = Array(score[:times]).map(&:to_i)
      score.presence if score[:times].any?
    end
  end

  # existing category or a new one ("new")
  def group_score_category_id
    return params[:group_score_category_id] unless params[:group_score_category_id] == 'new'

    category = GroupScoreCategory.create!(competition_id: @competition.id,
                                          name: params[:category_name].presence || 'default',
                                          group_score_type_id: params[:group_score_type_id])
    log_change(category, serializer: GroupScoreCategorySerializer)
    category.id
  end

  # categories (group disciplines) or single disciplines to import into
  def assign_target_options
    categories = GroupScoreCategory.joins(:group_score_type).where(competition_id: @competition.id)
                                   .where(group_score_types: { discipline: @discipline })
    @category_options = categories.decorate.map { ["#{it.name} - #{it.group_score_type}", it.id] } +
                        [['Neue Kategorie anlegen', 'new']]
    @group_score_type_options = GroupScoreType.where(discipline: @discipline).reorder(:name).pluck(:name, :id)
    @single_discipline_options = SingleDiscipline.where(key: @discipline)
                                                 .map { ["#{it.name} - #{it.description}", it.id] }
  end

  def render_create_error(message)
    @error = message
    check
  end
end
