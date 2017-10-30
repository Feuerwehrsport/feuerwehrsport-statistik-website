class API::CompetitionFilesController < API::BaseController
  api_actions :create, change_log: true
  belongs_to Competition

  def create
    @competition_files = params.require(:competition_file).values.map do |competition_file_params|
      CompetitionFile.new(competition: parent_resource, file: competition_file_params[:file], keys_params: competition_file_params)
    end

    @saved = false
    if @competition_files.all?(&:valid?)
      CompetitionFile.transaction do
        @saved = @competition_files.all?(&:save!)
      end
    end

    if @saved
      @competition_files.each do |competition_file|
        hash = hash_for_logging(competition_file)
        perform_logging(
          after_hash: hash,
          model_class: CompetitionFile,
        )
      end
      clean_cache_and_build_new
    end
    redirect_to(competition_path(parent_resource, anchor: 'toc-dateien'))
  end
end
