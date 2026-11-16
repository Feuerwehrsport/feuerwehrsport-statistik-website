# frozen_string_literal: true

# "Fehler mit diesem Team melden" and logo upload: change requests for the administrators
class Contributions::TeamChangeRequestsController < Contributions::BaseController
  # the key of the change request is "team-<kind>"
  KINDS = %w[merge correction logo other].freeze
  MAX_LOGO_SIZE = 10.megabytes

  before_action :assign_team

  def new
    authorize!(:create, ChangeRequest)
    @kind = params[:kind].presence_in(KINDS)
    assign_kind_data
  end

  def create
    authorize!(:create, ChangeRequest)
    @kind = params[:kind].presence_in(KINDS)
    @error, data, files = change_request_data
    return render_error if @error

    create_change_request("team-#{@kind}", data, files || [])
    render :created
  end

  private

  def assign_team
    @team = Team.find(params[:team_id]).decorate
  end

  # ids are strings like the former api requests (FormData)
  def change_request_data
    team_id = @team.id.to_s
    case @kind
    when 'merge'
      correct_team = Team.where.not(id: @team.id).find_by(id: params[:correct_team_id])
      return 'Bitte wähle die richtige Mannschaft aus.' if correct_team.nil?

      [nil, { team_id:, correct_team_id: correct_team.id.to_s }]
    when 'correction'
      team = params.fetch(:team, {}).permit(:name, :shortcut, :status).to_h.transform_values { |v| v.to_s.strip }
      return 'Bitte gib Name und Abkürzung an.' if team['name'].blank? || team['shortcut'].blank?
      return 'Bitte wähle einen gültigen Typ.' unless Team::STATUS.key?(team['status'].to_s.to_sym)

      [nil, { team_id:, team: }]
    when 'logo'
      logo = params[:logo]
      unless logo.is_a?(ActionDispatch::Http::UploadedFile) && logo_content_type?(logo.content_type.to_s)
        return 'Bitte wähle ein Bild oder eine PDF-Datei aus.'
      end
      return 'Die Datei ist zu groß (maximal 10 MB).' if logo.size > MAX_LOGO_SIZE

      [nil, { team_id: }, [logo]]
    when 'other'
      description = params[:description].to_s.strip
      return 'Bitte beschreibe das Problem.' if description.blank?

      [nil, { team_id:, description: }]
    else
      'Bitte wähle das Problem aus.'
    end
  end

  def logo_content_type?(content_type)
    content_type.start_with?('image/') || content_type == 'application/pdf'
  end

  def render_error
    assign_kind_data
    render :new, status: :unprocessable_content
  end

  def assign_kind_data
    @teams = search_teams if @kind == 'merge'
    return unless @kind == 'correction'

    # unsaved copy for the form, with the entered values after an error
    @team_form = Team.new(@team.object.attributes.slice('name', 'shortcut', 'status'))
    input = params.fetch(:team, {}).permit(:name, :shortcut, :status)
    input.delete(:status) unless Team::STATUS.key?(input[:status].to_s.to_sym) # enum raises for unknown values
    @team_form.assign_attributes(input)
  end

  def search_teams
    return Team.none if params[:q].to_s.strip.length < 2

    Team.where_name_like(params[:q].to_s).where.not(id: @team.id).reorder(:name).limit(30).decorate
  end
end
