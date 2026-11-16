# frozen_string_literal: true

# upload of result files (PDF) for a competition, with the contained results per file
class Contributions::CompetitionFilesController < Contributions::BaseController
  before_action :assign_competition

  def new
    authorize!(:create, CompetitionFile)
  end

  def create
    authorize!(:create, CompetitionFile)
    @competition_files = file_params.filter_map do |row|
      next if row[:file].blank?

      CompetitionFile.new(competition: @competition.object, file: row[:file], keys_params: row)
    end

    if @competition_files.empty?
      @error = 'Bitte wähle mindestens eine Datei aus.'
    elsif !@competition_files.all?(&:valid?)
      @error = 'Es dürfen nur PDF-Dateien hochgeladen werden.'
    end
    return render(:new, status: :unprocessable_content) if @error

    CompetitionFile.transaction do
      @competition_files.each do |competition_file|
        competition_file.save!
        log_change(competition_file, serializer: CompetitionFileSerializer)
      end
    end
    clean_cache
    render :created
  end

  private

  def assign_competition
    @competition = Competition.find(params[:competition_id]).decorate
  end

  # rows of competition_file[<index>][file|<key>]
  def file_params
    rows = params.fetch(:competition_file, {})
    rows = rows.values if rows.is_a?(ActionController::Parameters)
    Array(rows).grep(ActionController::Parameters).map { |row| row.permit(:file, *CompetitionFile::POSSIBLE_KEYS) }
  end
end
