# frozen_string_literal: true

# "Fehler oder Hinweis melden" for a competition and "Fehler melden" for one of its result files
class Contributions::CompetitionChangeRequestsController < Contributions::BaseController
  # the key of the change request is "competition-<kind>"
  KINDS = %w[change-name add-hint file-error].freeze

  before_action :assign_competition

  def new
    authorize!(:create, ChangeRequest)
    @kind = params[:kind].presence_in(KINDS)
    assign_file if @kind == 'file-error'
  end

  def create
    authorize!(:create, ChangeRequest)
    @kind = params[:kind].presence_in(KINDS)
    assign_file if @kind == 'file-error'
    @error, data = change_request_data
    return render(:new, status: :unprocessable_content) if @error

    create_change_request("competition-#{@kind}", data)
    render :created
  end

  private

  def assign_competition
    @competition = Competition.find(params[:competition_id]).decorate
  end

  def assign_file
    @file = @competition.object.competition_files.find(params[:file_id])
  end

  # ids are strings and the keys the same as in the former api requests (FormData)
  def change_request_data
    competition_id = @competition.id.to_s
    case @kind
    when 'change-name'
      name = params[:name].to_s.strip
      return 'Bitte gib einen Namen an.' if name.blank?

      [nil, { competition_id:, name: }]
    when 'add-hint'
      hint = params[:hint].to_s.strip
      return 'Bitte beschreibe deinen Hinweis.' if hint.blank?

      [nil, { competition_id:, hint: }]
    when 'file-error'
      description = params[:description].to_s.strip
      return 'Bitte beschreibe den Fehler in der Datei.' if description.blank?

      [nil, { competition_id:, fileId: @file.id.to_s, description: }]
    else
      'Bitte wähle aus, was du melden möchtest.'
    end
  end
end
