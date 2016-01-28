module API
  class CompetitionsController < BaseController
    include CRUD::CreateAction
    include CRUD::ShowAction
    include CRUD::IndexAction
    include CRUD::UpdateAction
    include CRUD::ChangeLogSupport
    
    before_action :assign_instance_for_files, only: :files

    def files
      @competition_files = params.require(:competition_file).values.map do |competition_file_params|
        CompetitionFile.new(competition: resource_instance, file: competition_file_params[:file], keys_params: competition_file_params)
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
      redirect_to(competition_path(resource_instance, anchor: 'toc-dateien'))
    end

    protected

    def assign_instance_for_files
      assign_existing_instance
      authorize!(:create, CompetitionFile)
      self.resource_instance = resource_instance.decorate
    end

    def resource_instance_show_object
      ExtendedCompetitionSerializer.new(resource_instance)
    end

    def create_permitted_attributes
      super.permit(:name, :place_id, :event_id, :date)
    end

    def update_permitted_attributes
      super.permit(:name, :score_type_id)
    end
  end
end
